#!/bin/sh

# OIDC Configuration: 请和values/auth/oids-values.yaml中的一致.
OIDC_CLIENT_ID=7c51a6b92dfebfa55d96
OIDC_CLIENT_SECRET=bcb3dc222a07fad21aabdd5035dadba2f09e05d6
OIDC_DISCOVERY_ADDR=http://casdoor:8000/.well-known/openid-configuration
OIDC_INTROSPECTION_ENDPOINT=http://casdoor:8000/api/login/oauth/introspect

# apisix 管理地址
APISIX_ADDR=10.233.63.159:9180
# 认证头,和 helm yaml中一致
AUTH="X-API-KEY: costrict-2025-admin"
# 是否允许apisix插件(主要是 limit-req和limit-count)无法使用时，依旧可以访问服务，内网可信用户可以设置维true.
Allow_DEGRADATION="false"

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


# 全局数组用于记录成功和失败的名称
SUCCESS_NAMES=()
FAILURE_NAMES=()

# 函数1: 检查HTTP响应状态
# 参数1: 名称
# 参数2: 内容
check_http_status() {
    local name="$1"
    local content="$2"
    echo $content
    # 使用正则表达式检查响应内容
    if [[ "$content" == *'{"key":"/apisix/'* ]]; then
        echo "$name 配置成功"
        SUCCESS_NAMES+=("$name")
    else
        echo "$name 配置失败"
        FAILURE_NAMES+=("$name")
    fi
}

# 函数2: 输出详细统计结果
summary() {
    echo "=== 配置检查详细结果 ==="
    echo "成功配置的项目:"
    if [ ${#SUCCESS_NAMES[@]} -eq 0 ]; then
        echo "  无"
    else
        for name in "${SUCCESS_NAMES[@]}"; do
            echo "  - $name"
        done
    fi
    
    echo ""
    echo "失败配置的项目:"
    if [ ${#FAILURE_NAMES[@]} -eq 0 ]; then
        echo "  无"
    else
        for name in "${FAILURE_NAMES[@]}"; do
            echo "  - $name"
        done
    fi
    
    echo ""
    echo "总计: 成功 ${#SUCCESS_NAMES[@]}, 失败 ${#FAILURE_NAMES[@]}"
}

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

RESPONSE=$(curl -i http://$APISIX_ADDR/apisix/admin/routes -H "$AUTH" -H "$TYPE" -X PUT -d '{
  "id": "oidc-auth",
  "name": "oidc-auth-routes",
  "uris": [
    "/oidc-auth/api/v1/plugin*",
    "/oidc-auth/api/v1/manager*"
  ],
  "plugins": {
    "limit-count": {
        "count": 1200,
        "key": "$http_zgsm_client_id$http_authorization",
        "key_type": "var_combination",
        "policy": "local",
        "rejected_code": 429,
        "show_limit_quota_header": true,
        "time_window": 60,
        "allow_degradation": '$Allow_DEGRADATION'
      },
      "limit-req": {
        "rate": 100,
        "burst": 300,
        "rejected_code": 429,
        "key_type": "var_combination",
        "key": "$http_zgsm_client_id$http_authorization",
        "allow_degradation": '$Allow_DEGRADATION'
      },
      "request-id": {
        "header_name": "X-Request-Id",
        "include_in_response": true,
        "algorithm": "uuid"
      }
  },
  "upstream_id": "oidc-auth"
}')
check_http_status "OIDC Auth" "$RESPONSE"


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

RESPONSE=$(curl -i http://$APISIX_ADDR/apisix/admin/routes -H "$AUTH" -H "$TYPE" -X PUT -d '{
  "id": "casdoor",
  "name": "casdoor-routes",
  "upstream_id": "casdoor",
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
  "plugins": {
    "limit-count": {
      "count": 600,
      "key_type": "var_combination",
      "policy": "local",
      "rejected_code": 429,
      "show_limit_quota_header": true,
      "time_window": 60,
      "allow_degradation": '$Allow_DEGRADATION'
    },
    "limit-req": {
      "rate": 600,
      "burst": 3000,
      "rejected_code": 429,
      "key_type": "var_combination",
      "key": "$http_zgsm_client_id$http_authorization",
      "allow_degradation": '$Allow_DEGRADATION'
    },
    "request-id": {
        "header_name": "X-Request-Id",
        "include_in_response": true,
        "algorithm": "uuid"
    }
  }
}')
check_http_status "Casdoor" "$RESPONSE"


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

RESPONSE=$(curl -i http://$APISIX_ADDR/apisix/admin/routes -H "$AUTH" -H "$TYPE" -X PUT -d '{
  "uris": [
    "/ai-gateway/api/v1/models"
  ],
  "id": "ai-gateway",
  "name": "ai-gateway",
  "upstream_id": "ai-gateway",
  "status": 1,
  "plugins": {
    "limit-count": {
      "count": 600,
      "key_type": "var_combination",
      "policy": "local",
      "rejected_code": 429,
      "show_limit_quota_header": true,
      "time_window": 60,
      "allow_degradation": '$Allow_DEGRADATION'
    },
    "limit-req": {
      "rate": 100,
      "burst": 200,
      "rejected_code": 429,
      "key_type": "var_combination",
      "key": "$http_zgsm_client_id$http_authorization",
      "allow_degradation": '$Allow_DEGRADATION'
    },
    "request-id": {
      "header_name": "X-Request-Id",
      "include_in_response": true,
      "algorithm": "uuid"
    }
  }
}')
check_http_status "AI Gateway" "$RESPONSE"

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

RESPONSE=$(curl -i http://$APISIX_ADDR/apisix/admin/routes -H "$AUTH" -H "$TYPE" -X PUT -d '{
  "uris": ["/chat-rag/api/v1/chat/*"],
  "id": "chat-rag",
  "name": "chat-rag-api",
  "upstream_id": "chat-rag",
  "plugins": {
    "limit-req": {
      "rate": 10,
      "burst": 20,
      "rejected_code": 429,
      "key_type": "var_combination",
      "key": "$http_zgsm_client_id$http_authorization",
      "allow_degradation": '$Allow_DEGRADATION'
    },
    "limit-count": {
      "count": 120,
      "key": "$http_zgsm_client_id$http_authorization",
      "key_type": "var_combination",
      "policy": "local",
      "rejected_code": 429,
      "show_limit_quota_header": true,
      "time_window": 60,
      "allow_degradation": '$Allow_DEGRADATION'
    },
    "openid-connect": {
      "client_id": "'"$OIDC_CLIENT_ID"'",
      "client_secret": "'"$OIDC_CLIENT_SECRET"'",
      "discovery": "'"$OIDC_DISCOVERY_ADDR"'",
      "introspection_endpoint": "'"$OIDC_INTROSPECTION_ENDPOINT"'",
      "introspection_endpoint_auth_method": "client_secret_basic",
      "introspection_interval": 600,
      "bearer_only": true,
      "set_userinfo_header": true,
      "ssl_verify": false,
      "scope": "openid profile email"
    },
    "request-id": {
      "header_name": "X-Request-Id",
      "include_in_response": true,
      "algorithm": "uuid"
    }
  }
}')
check_http_status "ChatRAG" "$RESPONSE"

# ****
# CLI Tools Configuration
echo "正在配置 CLI Tools 模块..."
curl -i http://$APISIX_ADDR/apisix/admin/upstreams -H "$AUTH" -H "$TYPE" -X PUT -d '{
    "id": "costrict-apps",
    "nodes": {
      "portal:8080": 1
    },
    "type": "roundrobin"
  }'
  
RESPONSE=$(curl -i http://$APISIX_ADDR/apisix/admin/routes -H "$AUTH" -H "$TYPE" -X PUT -d '{
    "id": "costrict-apps",
    "uris": ["/", "/index", "/index.html", "/costrict/*"],
    "name": "costrict-apps",
    "upstream_id": "costrict-apps",
    "plugins": {
      "proxy-rewrite": {
        "regex_uri": ["^/$", "/index.html", "^/index$", "/index.html", "^/index.html$", "/index.html"]
      },
      "limit-req": {
        "rate": 100,
        "burst": 200,
        "rejected_code": 429,
        "key_type": "var_combination",
        "key": "$http_zgsm_client_id$http_authorization",
        "allow_degradation": '$Allow_DEGRADATION'
      },
      "limit-count": {
        "count": 1800,
        "key": "$http_zgsm_client_id$http_authorization",
        "key_type": "var_combination",
        "policy": "local",
        "rejected_code": 429,
        "show_limit_quota_header": true,
        "time_window": 60,
        "allow_degradation": '$Allow_DEGRADATION'
      },
      "request-id": {
        "header_name": "X-Request-Id",
        "include_in_response": true,
        "algorithm": "uuid"
      }
    }
  }')
check_http_status "CLI Tools (Portal)" "$RESPONSE"

# ****
# Code Review Configuration
echo "正在配置 Code Review 模块..."

# Issue Configuration
echo "正在配置 Code Review - Issue 模块..."

curl -i http://$APISIX_ADDR/apisix/admin/upstreams -H "$AUTH" -H "$TYPE" -X PUT -d '{
    "id": "issue-manager",
    "nodes": {
      "issue-manager:8080": 1
    },
    "type": "roundrobin"
  }'


RESPONSE=$(curl -i  http://$APISIX_ADDR/apisix/admin/routes -H "$AUTH" -H "$TYPE" -X PUT -d '{
    "id": "issue-resources",
    "name": "issue-resources",
    "uris": ["/issue/*","/issue-manager/*"],
    "upstream_id": "issue-manager"
  }')

check_http_status "Code Review - Issue" "$RESPONSE"

# Manager
echo "正在配置 Code Review - Manager 模块..."

curl -i http://$APISIX_ADDR/apisix/admin/upstreams -H "$AUTH" -H "$TYPE" -X PUT -d '{
  "id": "review-manager",
  "nodes": {
    "review-manager:8080": 1
  },
  "type": "roundrobin"
}'

RESPONSE=$(curl -i http://$APISIX_ADDR/apisix/admin/routes -H "$AUTH" -H "$TYPE" -X PUT -d '{
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
        "introspection_interval": 600,
        "bearer_only": true,
        "set_userinfo_header": true,
        "ssl_verify": false,
        "scope": "openid profile email"
      },
      "limit-req": {
        "rate": 10,
        "burst": 20,
        "rejected_code": 429,
        "key_type": "var_combination",
        "key": "$http_zgsm_client_id$http_authorization",
        "allow_degradation": '$Allow_DEGRADATION'
      },
      "limit-count": {
        "count": 360,
        "key": "$http_zgsm_client_id$http_authorization",
        "key_type": "var_combination",
        "policy": "local",
        "rejected_code": 429,
        "show_limit_quota_header": true,
        "time_window": 60,
        "allow_degradation": '$Allow_DEGRADATION'
      },
      "request-id": {
        "header_name": "X-Request-Id",
        "include_in_response": true,
        "algorithm": "uuid"
      }
    }
  }')


check_http_status "Code Review - Manager" "$RESPONSE"

# ****
# Code Completion Configuration
echo "正在配置 Code Completion 模块..."
curl -i http://$APISIX_ADDR/apisix/admin/upstreams -H "$AUTH" -H "$TYPE" -X PUT  -d '{
    "id": "code-completion",
    "nodes": {
      "code-completion:8080": 1
    },
    "type": "roundrobin"
  }'

RESPONSE=$(curl -i  http://$APISIX_ADDR/apisix/admin/routes -H "$AUTH" -H "$TYPE" -X PUT -d '{
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
        "introspection_interval": 240,
        "ssl_verify": false
      },
      "limit-req": {
        "rate": 10,
        "burst": 10,
        "rejected_code": 503,
        "key_type": "var_combination",
        "key": "$http_zgsm_client_id$http_authorization",
        "allow_degradation": '$Allow_DEGRADATION'
      },
      "limit-count": {
        "count": 240,
        "key": "$http_zgsm_client_id$http_authorization",
        "key_type": "var_combination",
        "policy": "local",
        "rejected_code": 429,
        "show_limit_quota_header": true,
        "time_window": 60,
        "allow_degradation": '$Allow_DEGRADATION'
      },
      "request-id": {
        "header_name": "X-Request-Id",
        "include_in_response": true,
        "algorithm": "uuid"
      }
    }
  }')
check_http_status "Code Completion" "$RESPONSE"

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

RESPONSE=$(curl -i http://$APISIX_ADDR/apisix/admin/routes -H "$AUTH" -H "$TYPE" -X PUT -d '{
    "id": "credit-manager",
    "name": "credit-manager-routes",
    "uris": ["/credit/manager*"],
    "upstream_id": "credit-manager",
    "plugins": {
      "limit-req": {
        "rate": 10,
        "burst": 30,
        "rejected_code": 429,
        "key_type": "var_combination",
        "key": "$http_zgsm_client_id$http_authorization$cookie_casdoor_session_id",
        "allow_degradation": '$Allow_DEGRADATION'
      },
      "limit-count": {
        "count": 20,
        "key": "$http_zgsm_client_id$http_authorization$cookie_casdoor_session_id",
        "key_type": "var_combination",
        "policy": "local",
        "rejected_code": 429,
        "show_limit_quota_header": true,
        "time_window": 60,
        "allow_degradation": '$Allow_DEGRADATION'
      },
      "request-id": {
        "header_name": "X-Request-Id",
        "include_in_response": true,
        "algorithm": "uuid"
      }
      
    }
}')
check_http_status "Credit Manager" "$RESPONSE"


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

RESPONSE=$(curl -i  http://$APISIX_ADDR/apisix/admin/routes -H "$AUTH" -H "$TYPE" -X PUT -d '{
    "id": "quota-manager",
    "name": "quota-manager",
    "uris": ["/quota-manager/api/v1/quota*"],
    "upstream_id": "quota-manager",
    "plugins": {
      "limit-count": {
        "count": 120,
        "key": "$http_zgsm_client_id$http_authorization",
        "key_type": "var_combination",
        "policy": "local",
        "rejected_code": 429,
        "show_limit_quota_header": true,
        "time_window": 60,
        "allow_degradation": '$Allow_DEGRADATION'
      },
      "limit-req": {
        "rate": 10,
        "burst": 30,
        "rejected_code": 429,
        "key_type": "var_combination",
        "key": "$http_zgsm_client_id$http_authorization",
        "allow_degradation": '$Allow_DEGRADATION'
      },
      "openid-connect": {
        "client_id": "'"$OIDC_CLIENT_ID"'",
        "client_secret": "'"$OIDC_CLIENT_SECRET"'",
        "discovery": "'"$OIDC_DISCOVERY_ADDR"'",
        "introspection_endpoint": "'"$OIDC_INTROSPECTION_ENDPOINT"'",
        "introspection_endpoint_auth_method": "client_secret_basic",
        "introspection_interval": 120,
        "bearer_only": true,
        "scope": "openid profile email"
      },
      "request-id": {
        "header_name": "X-Request-Id",
        "include_in_response": true,
        "algorithm": "uuid"
      }
    }
  }')
check_http_status "Quota Manager" "$RESPONSE"

# ***
# CodeBase
echo "正在配置 CodeBase Embedder 模块..."
curl -i http://$APISIX_ADDR/apisix/admin/upstreams -H "$AUTH" -H "$TYPE" -X PUT  -d '{
    "id": "codebase-embedder",
    "nodes": {
      "codebase-embedder-svc:8888": 1
    },
    "type": "roundrobin"
  }'

RESPONSE=$(curl -i http://$APISIX_ADDR/apisix/admin/routes -H "$AUTH" -H "$TYPE" -X PUT -d '{
  "id": "codebase-embedder",
  "uris": [
    "/codebase-embedder/*"
  ],
  "upstream_id": "codebase-embedder",
  "name": "codebase-embedder",
  "plugins": {
    "openid-connect": { 
      "client_id": "'"$OIDC_CLIENT_ID"'",
      "client_secret": "'"$OIDC_CLIENT_SECRET"'",
      "discovery": "'"$OIDC_DISCOVERY_ADDR"'",
      "introspection_endpoint": "'"$OIDC_INTROSPECTION_ENDPOINT"'",
      "introspection_endpoint_auth_method": "client_secret_basic",
      "introspection_interval": 600,
      "bearer_only": true,
      "scope": "openid profile email",
      "set_access_token_header": true,
      "set_id_token_header": true,
      "set_userinfo_header": true,
      "ssl_verify": false
    },
    "limit-count": {
      "count": 360,
      "key": "$http_zgsm_client_id$http_authorization",
      "key_type": "var_combination",
      "policy": "local",
      "rejected_code": 429,
      "show_limit_quota_header": true,
      "time_window": 60,
      "allow_degradation": '$Allow_DEGRADATION'
    },
    "limit-req": {
      "rate": 10,
      "burst": 30,
      "rejected_code": 429,
      "key_type": "var_combination",
      "key": "$http_zgsm_client_id$http_authorization",
      "allow_degradation": '$Allow_DEGRADATION'
    },
    "request-id": {
      "header_name": "X-Request-Id",
      "include_in_response": true,
      "algorithm": "uuid"
    }
  }
}')

check_http_status "Codebase-embedder" "$RESPONSE"



# ****
# PushGateway Configuration
echo "正在配置 PushGateway 模块..."
curl -i http://$APISIX_ADDR/apisix/admin/upstreams -H "$AUTH" -H "$TYPE" -X PUT -d '{
    "id": "pushgateway",
    "nodes": {
      "pushgateway:9091": 1
    },
    "type": "roundrobin"
  }'

RESPONSE=$(curl -i http://$APISIX_ADDR/apisix/admin/routes -H "$AUTH" -H "$TYPE" -X PUT -d '{
    "id": "pushgateway",
    "uri": "/pushgateway/api/v1/*",
    "name": "pushgateway",
    "upstream_id": "pushgateway",
    "plugins": {
      "proxy-rewrite": {
          "regex_uri": ["^/pushgateway/api/v1/(.*)", "/$1"]
      },
      "limit-count": {
        "count": 60,
        "key": "$http_zgsm_client_id$http_authorization",
        "key_type": "var_combination",
        "policy": "local",
        "rejected_code": 429,
        "show_limit_quota_header": true,
        "time_window": 60,
        "allow_degradation": '$Allow_DEGRADATION'
      },
      "limit-req": {
        "rate": 10,
        "burst": 30,
        "rejected_code": 429,
        "key_type": "var_combination",
        "key": "$http_zgsm_client_id$http_authorization",
        "allow_degradation": '$Allow_DEGRADATION'
      },
      "openid-connect": {
        "client_id": "'"$OIDC_CLIENT_ID"'",
        "client_secret": "'"$OIDC_CLIENT_SECRET"'",
        "discovery": "'"$OIDC_DISCOVERY_ADDR"'",
        "introspection_endpoint": "'"$OIDC_INTROSPECTION_ENDPOINT"'",
        "introspection_endpoint_auth_method": "client_secret_basic",
        "introspection_interval": 240,
        "bearer_only": true,
        "scope": "openid profile email"
      },
      "request-id": {
        "header_name": "X-Request-Id",
        "include_in_response": true,
        "algorithm": "uuid"
      }
    }
  }')
check_http_status "PushGateway" "$RESPONSE"

# ****
# Tunnel Manager Configuration
echo "正在配置 Tunnel Manager 模块..."
curl -i http://$APISIX_ADDR/apisix/admin/upstreams -H "$AUTH" -H "$TYPE" -X PUT  -d '{
    "id": "tunnel-manager",
    "nodes": {
      "tunnel-manager:8080": 1
    },
    "type": "roundrobin"
  }'

RESPONSE=$(curl -i  http://$APISIX_ADDR/apisix/admin/routes -H "$AUTH" -H "$TYPE" -X PUT -d '{
    "uris": ["/tunnel-manager/*"],
    "id": "tunnel-manager",
    "name": "tunnel-manager",
    "upstream_id": "tunnel-manager",
    "plugins": {
      "openid-connect": {
        "client_id": "'"$OIDC_CLIENT_ID"'",
        "client_secret": "'"$OIDC_CLIENT_SECRET"'",
        "discovery": "'"$OIDC_DISCOVERY_ADDR"'",
        "introspection_endpoint": "'"$OIDC_INTROSPECTION_ENDPOINT"'",
        "introspection_endpoint_auth_method": "client_secret_basic",
        "introspection_interval": 300,
        "bearer_only": true,
        "set_userinfo_header": true,
        "ssl_verify": false,
        "scope": "openid profile email"
      },
      "request-id": {
        "header_name": "X-Request-Id",
        "include_in_response": true,
        "algorithm": "uuid"
      }
    }
  }')
check_http_status "Tunnel Manager" "$RESPONSE"


# ****
# Cotun Configuration
echo "正在配置 Coutn 模块..."
curl -i http://$APISIX_ADDR/apisix/admin/upstreams -H "$AUTH" -H "$TYPE" -X PUT  -d '{
    "id": "cotun",
    "nodes": {
      "cotun:8080": 1
    },
    "type": "roundrobin"
  }'

RESPONSE=$(curl -i  http://$APISIX_ADDR/apisix/admin/routes -H "$AUTH" -H "$TYPE" -X PUT -d '{
    "uris": ["/ws", "/ws/*"],
    "id": "cotun",
    "name": "cotun",
    "upstream_id": "cotun",
    "plugins": {
      "request-id": {
        "header_name": "X-Request-Id",
        "include_in_response": true,
        "algorithm": "uuid"
      },
      "limit-count": {
        "count": 60,
        "key": "$http_zgsm_client_id$http_authorization",
        "key_type": "var_combination",
        "policy": "local",
        "rejected_code": 429,
        "show_limit_quota_header": true,
        "time_window": 60,
        "allow_degradation": '$Allow_DEGRADATION'
      },
      "limit-req": {
        "rate": 5,
        "burst": 10,
        "rejected_code": 429,
        "key_type": "var_combination",
        "key": "$http_zgsm_client_id$http_authorization",
        "allow_degradation": '$Allow_DEGRADATION'
      },
      "openid-connect": {
        "client_id": "'"$OIDC_CLIENT_ID"'",
        "client_secret": "'"$OIDC_CLIENT_SECRET"'",
        "discovery": "'"$OIDC_DISCOVERY_ADDR"'",
        "introspection_endpoint": "'"$OIDC_INTROSPECTION_ENDPOINT"'",
        "introspection_endpoint_auth_method": "client_secret_basic",
        "introspection_interval": 120,
        "bearer_only": true,
        "scope": "openid profile email"
      }
    }
  }')
check_http_status "Cotun" "$RESPONSE"

# ****
# 执行结果统计
echo ""
echo "=========================================="
echo "         APISIX 路由配置执行结果统计"
echo "=========================================="
summary