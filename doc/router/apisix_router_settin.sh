#!/bin/sh

# OIDC Configuration: 请和values/auth/oids-values.yaml中的一致.
OIDC_CLIENT_ID=7c51a6b92dfebfa55d96
OIDC_CLIENT_SECRET=7c51a6b92dfebfa55d96
OIDC_DISCOVERY_ADDR=http://casdoor:8000/.well-known/openid-configuration
OIDC_INTROSPECTION_ENDPOINT=http://casdoor:8000/api/login/oauth/introspect

APISIX_ADDR=10.233.8.7:9180
AUTH="X-API-KEY: costrict-2025-admin"
TYPE="Content-Type: application/json"

# 初始化成功和失败的模块计数器
SUCCESS_MODULES=0
FAILED_MODULES=0

# 函数：检查命令执行状态并更新计数器
check_module_status() {
    if [ $? -eq 0 ]; then
        echo "✓ $1 模块执行成功"
        SUCCESS_MODULES=$((SUCCESS_MODULES + 1))
    else
        echo "✗ $1 模块执行失败"
        FAILED_MODULES=$((FAILED_MODULES + 1))
    fi
}

# ****
# AI Gateway Configuration
echo "正在配置 AI Gateway 模块..."
curl -i http://$APISIX_ADDR/apisix/admin/upstreams -H "$AUTH" -H "$TYPE" -X PUT -d '{
    "id": "ai-gateway",
    "nodes": {
      "higress-gateway:80": 1
    },
    "type": "roundrobin"
  }'

curl -i http://$APISIX_ADDR/apisix/admin/routes -H "$AUTH" -H "$TYPE" -X PUT -d '{
    "uris": [
      "/ai-gateway/api/v1/models"
    ],
    "id": "ai-gateway",
    "name": "ai-gateway",
    "upstream_id": "ai-gateway",
    "status": 1
  }'
check_module_status "AI Gateway"

# ****
# Casdoor Configuration
echo "正在配置 Casdoor 模块..."
curl -i http://$APISIX_ADDR/apisix/admin/upstreams -H "$AUTH" -H "$TYPE" -X PUT -d '{
    "id": "casdoor",
    "nodes": {
      "casdoor:8000": 1
    },
    "type": "roundrobin"
  }'

curl -i http://$APISIX_ADDR/apisix/admin/routes -H "$AUTH" -H "$TYPE" -X PUT -d '{
  "uris": [
    "/login/oauth/*",
    "/api/login/oauth/*",
    "/casdoor/*",
    "/static/*",
    "/api/get-app-login*",
    "/api/get-account*",
    "/api/get-application*",
    "/api/get-captcha*",
    "/api/send-verification-code*",
    "/api/login*",
    "/login/success",
    "/callback*"
  ],
  "id": "casdoor",
  "name": "casdoor-routes",
  "upstream_id": "casdoor"
}'
check_module_status "Casdoor"


# ****
# ChatRAG Configuration
echo "正在配置 ChatRAG 模块..."
curl -i http://$APISIX_ADDR/apisix/admin/upstreams -H "$AUTH" -H "$TYPE" -X PUT -d '{
    "id": "chat-rag",
    "nodes": {
      "chat-rag-svc:8888": 1
    },
    "type": "roundrobin"
  }'

curl -i http://$APISIX_ADDR/apisix/admin/routes -H "$AUTH" -H "$TYPE" -X PUT -d '{
    "uris": ["/chat-rag/api/v1/chat/*"],
    "id": "chat-rag",
    "name": "chat-rag-api",
    "upstream_id": "chat-rag",
    "plugins": {
      "request-id": {
        "include_in_response": true
      },
      "file-logger": {
        "include_req_body": true,
        "include_resp_body": true,
        "path": "logs/access.log"
      },
      "limit-count": {
        "count": 10000,
        "time_window": 86400,
        "rejected_code": 429,
        "key": "$remote_addr $http_x_forwarded_for",
        "key_type": "var_combination"
      },
      "limit-req": {
        "rate": 300,
        "burst": 300,
        "rejected_code": 429,
        "key_type": "var_combination",
        "key": "$remote_addr $http_x_forwarded_for"
      },
      "loki-logger": {
        "endpoint_addrs": ["http://loki.loki:3100"],
        "endpoint_uri": "/loki/api/v1/push",
        "include_req_body": true,
        "include_resp_body": true,
        "log_labels": {"job": "apisix"}
      },
      "openid-connect": {
        "client_id": "'"$OIDC_CLIENT_ID"'",
        "client_secret": "'"$OIDC_CLIENT_SECRET"'",
        "discovery": "'"$OIDC_DISCOVERY_ADDR"'",
        "introspection_endpoint": "'"$OIDC_INTROSPECTION_ENDPOINT"'",
        "introspection_endpoint_auth_method": "client_secret_basic",
        "introspection_interval": 60,
        "bearer_only": true,
        "set_userinfo_header": true,
        "ssl_verify": false,
        "scope": "openid profile email"
      }
    }
  }'
check_module_status "ChatRAG"

# ****
# CLI Tools Configuration
echo "正在配置 CLI Tools 模块..."
curl -i http://$APISIX_ADDR/apisix/admin/upstreams -H "$AUTH" -H "$TYPE" -X PUT -d '{
    "id": "shenma-client",
    "nodes": {
      "portal:8080": 1
    },
    "type": "roundrobin"
  }'
  
curl -i http://$APISIX_ADDR/apisix/admin/routes -H "$AUTH" -H "$TYPE" -X PUT -d '{
    "uri": "/shenma/*",
    "id": "shenma-client",
    "name": "shenma-client",
    "upstream_id": "shenma-client",
    "plugins": {
      "proxy-rewrite": {
        "regex_uri": ["^/shenma/api/v1(.*)", "/shenma-cli-tools$1"]
      },
      "file-logger": {
        "path": "logs/access.log",
        "include_req_body": false,
        "include_resp_body": false,
        "only_req_line": true
      },
      "limit-count": {
        "count": 100,
        "time_window": 60,
        "rejected_code": 429,
        "key_type": "var_combination",
        "key": "$remote_addr $http_x_forwarded_for"
      }
    }
  }'
check_module_status "CLI Tools"

# ****
# Code Review Configuration
echo "正在配置 Code Review 模块..."
curl -i http://$APISIX_ADDR/apisix/admin/upstreams -H "$AUTH" -H "$TYPE" -X PUT -d '{
    "id": "review-manager",
    "nodes": {
      "review-manager:8080": 1
    },
    "type": "roundrobin"
  }'

curl -i http://$APISIX_ADDR/apisix/admin/upstreams -H "$AUTH" -H "$TYPE" -X PUT -d '{
    "id": "issue-manager",
    "nodes": {
      "issue-manager:8080": 1
    },
    "type": "roundrobin"
  }'

curl -i http://$APISIX_ADDR/apisix/admin/routes -H "$AUTH" -H "$TYPE" -X PUT -d '{
    "id": "review-manager",
    "name": "review-manager-api",
    "uris": ["/review-manager/*"],
    "upstream_id": "review-manager",
    "plugins": {
      "openid-connect": {
         "client_id": "'"$OIDC_CLIENT_ID"'",
         "client_secret": "'"$OIDC_CLIENT_SECRET"'",
         "discovery": "'"$OIDC_DISCOVERY_ADDR"'",
         "introspection_endpoint": "'"$OIDC_INTROSPECTION_ENDPOINT"'",
         "introspection_endpoint_auth_method": "client_secret_basic",
         "bearer_only": true,
         "set_userinfo_header": true,
         "set_id_token_header": false,
         "ssl_verify": false
       },
      "limit-req": {
        "rate": 300,
        "burst": 300,
        "rejected_code": 429,
        "key_type": "var_combination",
        "key": "$remote_addr $http_x_forwarded_for"
      },
      "limit-count": {
        "count": 10000,
        "time_window": 86400,
        "rejected_code": 429,
        "key_type": "var_combination",
        "key": "$remote_addr $http_x_forwarded_for"
      }
    }
  }'

curl -i http://$APISIX_ADDR/apisix/admin/routes -H "$AUTH" -H "$TYPE" -X PUT -d '{
    "uri": "/issue-manager/*",
    "id": "issue-manager-api",
    "name": "issue-manager-api",
    "upstream_id": "issue-manager",
    "plugins": {
      "openid-connect": {
         "client_id": "'"$OIDC_CLIENT_ID"'",
         "client_secret": "'"$OIDC_CLIENT_SECRET"'",
         "discovery": "'"$OIDC_DISCOVERY_ADDR"'",
         "introspection_endpoint": "'"$OIDC_INTROSPECTION_ENDPOINT"'",
         "introspection_endpoint_auth_method": "client_secret_basic",
         "bearer_only": true,
         "set_userinfo_header": true,
         "set_id_token_header": false,
         "ssl_verify": false
       },
      "limit-req": {
        "rate": 300,
        "burst": 300,
        "rejected_code": 429,
        "key_type": "var_combination",
        "key": "$remote_addr $http_x_forwarded_for"
      },
      "limit-count": {
        "count": 10000,
        "time_window": 86400,
        "rejected_code": 429,
        "key_type": "var_combination",
        "key": "$remote_addr $http_x_forwarded_for"
      }
    }
  }'
check_module_status "Code Review"

# ****
# Code Completion V2 Configuration
echo "正在配置 Code Completion V2 模块..."
curl -i http://$APISIX_ADDR/apisix/admin/upstreams -H "$AUTH" -H "$TYPE" -X PUT  -d '{
    "id": "code-completion",
    "nodes": {
      "code-completion-svc:5000": 1
    },
    "type": "roundrobin"
  }'

curl -i  http://$APISIX_ADDR/apisix/admin/routes -H "$AUTH" -H "$TYPE" -X PUT -d '{
    "id": "code-completion",
    "name": "code-completion",
    "uris": ["/code-completion/api/v1/completions"],
    "upstream_id": "code-completion",
    "plugins": {
      "openid-connect": {
        "client_id": "'"$OIDC_CLIENT_ID"'",
        "client_secret": "'"$OIDC_CLIENT_SECRET"'",
        "discovery": "'"$OIDC_DISCOVERY_ADDR"'",
        "introspection_endpoint": "'"$OIDC_INTROSPECTION_ENDPOINT"'",
        "introspection_endpoint_auth_method": "client_secret_basic",
        "bearer_only": true,
        "ssl_verify": false
      },
      "limit-req": {
        "rate": 10,
        "burst": 10,
        "rejected_code": 503,
        "key_type": "var_combination",
        "key": "$remote_addr $http_x_forwarded_for"
      },
      "limit-count": {
        "count": 10000,
        "time_window": 86400,
        "rejected_code": 429,
        "key_type": "var_combination",
        "key": "$remote_addr $http_x_forwarded_for"
      },
      "file-logger": {
        "path": "logs/access.log",
        "include_req_body": true,
        "include_resp_body": true
      }
    }
  }'
check_module_status "Code Completion V2"

# ****
# Credit Manager Configuration
echo "正在配置 Credit Manager 模块..."
curl -i http://$APISIX_ADDR/apisix/admin/upstreams -H "$AUTH" -H "$TYPE" -X PUT -d '{
    "id": "credit-manager",
    "nodes": {
      "credit-manager:80": 1
    },
    "type": "roundrobin"
}'

curl -i http://$APISIX_ADDR/apisix/admin/routes -H "$AUTH" -H "$TYPE" -X PUT -d '{
    "id": "credit-manager",
    "name": "credit-manager-routes",
    "uris": ["/credit/manager*"],
    "upstream_id": "credit-manager",
    "plugins": {
      "limit-req": {
        "rate": 300,
        "burst": 300,
        "rejected_code": 429,
        "key_type": "var_combination",
        "key": "$remote_addr $http_x_forwarded_for"
      },
      "limit-count": {
        "count": 10000,
        "time_window": 86400,
        "rejected_code": 429,
        "key_type": "var_combination",
        "key": "$remote_addr $http_x_forwarded_for"
      }
    }
}'
check_module_status "Credit Manager"


# ****
# Issue Configuration
# Submit issue reports, page resources are hosted on the portal service, API '/api/feedbacks/issue' is implemented by chatgpt.
echo "正在配置 Issue 模块..."

# Define upstream for login-related page resources
curl -i http://$APISIX_ADDR/apisix/admin/upstreams -H "$AUTH" -H "$TYPE" -X PUT  -d '{
    "id": "portal",
    "nodes": {
        "portal:80": 1
    },
    "type": "roundrobin"
}'
check_module_status "Issue"

# ****
# OIDC Auth Configuration
echo "正在配置 OIDC Auth 模块..."
curl -i http://$APISIX_ADDR/apisix/admin/upstreams -H "$AUTH" -H "$TYPE" -X PUT -d '{
    "id": "oidc-auth",
    "nodes": {
      "oidc-auth:8080": 1
    },
    "type": "roundrobin"
  }'

curl -i http://$APISIX_ADDR/apisix/admin/routes -H "$AUTH" -H "$TYPE" -X PUT -d '{
  "id": "oidc-auth",
  "name": "oidc-auth-routes",
  "uris": [
    "/oidc-auth/api/v1/plugin*",
    "/oidc-auth/api/v1/manager*"
  ],
  "upstream_id": "oidc-auth"
}'
check_module_status "OIDC Auth"

# ****
# Quota Manager Configuration
echo "正在配置 Quota Manager 模块..."
curl -i http://$APISIX_ADDR/apisix/admin/upstreams -H "$AUTH" -H "$TYPE" -X PUT  -d '{
    "id": "quota-manager",
    "nodes": {
      "quota-manager-svc:8080": 1
    },
    "type": "roundrobin"
  }'

curl -i  http://$APISIX_ADDR/apisix/admin/routes -H "$AUTH" -H "$TYPE" -X PUT -d '{
    "id": "quota-manager",
    "name": "quota-manager",
    "uris": ["/quota-manager/api/v1/quota*"],
    "upstream_id": "quota-manager",
    "plugins": {
      "file-logger": {
        "include_req_body": true,
        "include_resp_body": true,
        "path": "logs/access.log"
      },
      "limit-count": {
        "allow_degradation": false,
        "count": 10000,
        "key_type": "var_combination",
        "key": "$remote_addr $http_x_forwarded_for",
        "policy": "local",
        "rejected_code": 429,
        "show_limit_quota_header": true,
        "time_window": 86400
      },
      "limit-req": {
        "allow_degradation": false,
        "burst": 300,
        "key": "$remote_addr $http_x_forwarded_for",
        "key_type": "var_combination",
        "nodelay": false,
        "policy": "local",
        "rate": 300,
        "rejected_code": 429
      },
      "openid-connect": {
        "client_id": "'"$OIDC_CLIENT_ID"'",
        "client_secret": "'"$OIDC_CLIENT_SECRET"'",
        "discovery": "'"$OIDC_DISCOVERY_ADDR"'",
        "introspection_endpoint": "'"$OIDC_INTROSPECTION_ENDPOINT"'",
        "introspection_endpoint_auth_method": "client_secret_basic",
        "introspection_interval": 60,
        "bearer_only": true,
        "scope": "openid profile email"
      }
    }
  }'
check_module_status "Quota Manager"

# ****
# 执行结果统计
echo ""
echo "=========================================="
echo "         APISIX 路由配置执行结果统计"
echo "=========================================="
echo "成功配置的模块数量: $SUCCESS_MODULES"
echo "失败配置的模块数量: $FAILED_MODULES"
echo "=========================================="

if [ $FAILED_MODULES -eq 0 ]; then
    echo "🎉 所有模块配置成功！"
    exit 0
else
    echo "⚠️  有 $FAILED_MODULES 个模块配置失败，请检查上述错误信息"
    exit 1
fi