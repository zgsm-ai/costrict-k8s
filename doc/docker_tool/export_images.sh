#!/bin/bash

# Docker镜像导出脚本
# 用法: ./export_images.sh [-i 镜像列表文件] [-o 输出目录] [-v]

# 不使用 set -e，因为我们希望即使某个镜像导出失败也能继续处理其他镜像

# 默认值
IMAGE_LIST_FILE="image_list.txt"
OUTPUT_DIR="./docker_images"
VERBOSE=false

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 显示帮助信息
show_help() {
    cat << EOF
Docker镜像导出脚本

用法: $0 [选项]

选项:
    -i, --image-list FILE    指定镜像列表文件 (默认: image_list.txt)
    -o, --output-dir DIR     指定输出目录 (默认: ./docker_images)
    -v, --verbose            启用详细输出
    -h, --help               显示此帮助信息

示例:
    $0 -i my_images.txt -o ./exports -v
    $0 --image-list images.txt --output-dir /path/to/exports

镜像列表文件格式:
    每行一个镜像名称，例如:
        nginx:latest
        redis:alpine
        postgres:13

EOF
}

# 解析命令行参数
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -i|--image-list)
                IMAGE_LIST_FILE="$2"
                shift 2
                ;;
            -o|--output-dir)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log_error "未知参数: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# 检查Docker是否可用
check_docker() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker未安装或不在PATH中"
        exit 1
    fi

    if ! docker info &> /dev/null; then
        log_error "Docker守护进程未运行或无权限访问"
        exit 1
    fi

    log_success "Docker环境检查通过"
}

# 检查镜像列表文件
check_image_list_file() {
    if [[ ! -f "$IMAGE_LIST_FILE" ]]; then
        log_error "镜像列表文件不存在: $IMAGE_LIST_FILE"
        exit 1
    fi

    if [[ ! -r "$IMAGE_LIST_FILE" ]]; then
        log_error "无法读取镜像列表文件: $IMAGE_LIST_FILE"
        exit 1
    fi

    # 检查文件是否为空
    if [[ ! -s "$IMAGE_LIST_FILE" ]]; then
        log_error "镜像列表文件为空: $IMAGE_LIST_FILE"
        exit 1
    fi

    log_info "使用镜像列表文件: $IMAGE_LIST_FILE"
}

# 创建输出目录
create_output_directory() {
    mkdir -p "$OUTPUT_DIR"
    if [[ ! -d "$OUTPUT_DIR" ]]; then
        log_error "无法创建输出目录: $OUTPUT_DIR"
        exit 1
    fi

    if [[ ! -w "$OUTPUT_DIR" ]]; then
        log_error "输出目录无写入权限: $OUTPUT_DIR"
        exit 1
    fi

    log_info "输出目录: $OUTPUT_DIR"
}

# 读取镜像列表
read_image_list() {
    local images=()
    
    while IFS= read -r line || [[ -n "$line" ]]; do
        # 跳过空行和注释行（以#开头）
        if [[ -n "$line" && ! "$line" =~ ^[[:space:]]*# ]]; then
            # 去除首尾空白字符
            image=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            if [[ -n "$image" ]]; then
                images+=("$image")
                if [[ "$VERBOSE" == true ]]; then
                    log_info "读取到镜像: $image"
                fi
            fi
        fi
    done < "$IMAGE_LIST_FILE"

    if [[ ${#images[@]} -eq 0 ]]; then
        log_error "镜像列表文件中没有有效的镜像名称"
        exit 1
    fi

    # 返回镜像数组
    printf '%s\n' "${images[@]}"
}

# 检查镜像是否存在
check_image_exists() {
    local image="$1"
    
    if docker image inspect "$image" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# 导出单个镜像
export_image() {
    local image="$1"
    local output_file="$OUTPUT_DIR/$(echo "$image" | tr '/:' '_').tar"
    
    log_info "正在导出镜像: $image"
    
    if ! check_image_exists "$image"; then
        log_warning "镜像不存在，跳过: $image"
        return 1
    fi

    # 导出镜像
    if docker save -o "$output_file" "$image"; then
        # 检查文件是否存在并获取大小
        if [[ -f "$output_file" ]]; then
            local file_size=$(du -h "$output_file" | cut -f1)
            log_success "镜像导出成功: $image -> $output_file (大小: $file_size)"
        else
            log_success "镜像导出成功: $image -> $output_file"
        fi
        
        if [[ "$VERBOSE" == true ]]; then
            log_info "镜像详情:"
            docker image inspect "$image" --format '{{.Id}} {{.Created}} {{.Size}}' | sed 's/^/  /'
        fi
        
        return 0
    else
        log_error "镜像导出失败: $image"
        return 1
    fi
}

# 生成导出报告
generate_report() {
    local report_file="$OUTPUT_DIR/export_report.txt"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    cat > "$report_file" << EOF
Docker镜像导出报告
===================

导出时间: $timestamp
镜像列表文件: $IMAGE_LIST_FILE
输出目录: $OUTPUT_DIR

导出的镜像:
EOF

    for tar_file in "$OUTPUT_DIR"/*.tar; do
        if [[ -f "$tar_file" ]]; then
            local image_name=$(basename "$tar_file" .tar | sed 's/_/:/g' | sed 's/_/\//g')
            local file_size=$(du -h "$tar_file" | cut -f1)
            echo "  - $image_name (大小: $file_size)" >> "$report_file"
        fi
    done

    echo "" >> "$report_file"
    echo "报告生成时间: $(date '+%Y-%m-%d %H:%M:%S')" >> "$report_file"
    
    log_info "导出报告已生成: $report_file"
}

# 主函数
main() {
    log_info "开始Docker镜像导出流程"
    
    # 解析命令行参数
    parse_arguments "$@"
    
    # 检查环境
    check_docker
    check_image_list_file
    create_output_directory
    
    # 读取镜像列表
    local images
    readarray -t images < <(read_image_list)
    
    # 统计变量
    local total_images=${#images[@]}
    local success_count=0
    local failure_count=0
    
    log_info "找到 $total_images 个镜像待导出"
    log_info "开始导出镜像"
    
    # 导出每个镜像
    for image in "${images[@]}"; do
        log_info "处理镜像: $image"
        if export_image "$image"; then
            ((success_count++))
            log_info "当前进度: $success_count/$total_images"
        else
            ((failure_count++))
            log_warning "跳过失败的镜像，继续处理下一个"
        fi
    done
    
    # 生成报告
    generate_report
    
    # 输出总结
    log_info "导出完成"
    log_info "总计: $total_images 个镜像"
    log_success "成功: $success_count 个镜像"
    if [[ $failure_count -gt 0 ]]; then
        log_error "失败: $failure_count 个镜像"
        log_warning "部分镜像导出失败，请检查上述错误信息"
    else
        log_success "所有镜像导出成功！"
    fi
}

# 脚本入口点
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi