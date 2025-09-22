#!/usr/bin/env python3
"""
Helm Charts 打包脚本
遍历charts目录，对每个chart执行helm package命令，并将结果输出到out目录
"""

import os
import shutil
import subprocess
import sys
from pathlib import Path

def run_command(command, cwd=None):
    """运行shell命令并返回结果"""
    print(f"执行命令: {command}")
    try:
        result = subprocess.run(
            command,
            shell=True,
            cwd=cwd,
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        print(f"命令执行成功: {result.stdout}")
        return result.stdout
    except subprocess.CalledProcessError as e:
        print(f"命令执行失败: {e.stderr}")
        sys.exit(1)

def copy_file(src, dst):
    """复制文件到目标目录"""
    print(f"复制文件: {src} -> {dst}")
    try:
        shutil.copy2(src, dst)
        print(f"文件复制成功: {dst}")
        return True
    except Exception as e:
        print(f"文件复制失败: {e}")
        return False

def package_helm_charts(charts_dir="charts", output_dir="out"):
    """
    打包Helm charts，支持嵌套目录结构
    
    Args:
        charts_dir (str): 包含Helm charts的目录
        output_dir (str): 输出目录
    """
    # 确保charts目录存在
    charts_path = Path(charts_dir)
    if not charts_path.exists():
        print(f"错误: charts目录 {charts_dir} 不存在")
        sys.exit(1)
    
    # 创建输出目录（相对于项目根目录）
    output_path = Path(output_dir)
    output_path.mkdir(exist_ok=True)
    print(f"创建输出目录: {output_path.absolute()}")
    
    # 遍历charts目录下的一级子目录，查找chart目录和tgz文件
    chart_dirs = []
    copied_files = []
    
    for first_level_dir in charts_path.iterdir():
        if first_level_dir.is_dir():
            # 首先检查一级目录中是否有tgz文件
            for item in first_level_dir.iterdir():
                if item.is_file() and item.suffix == '.tgz':
                    # 创建对应的输出子目录
                    output_subdir = output_path / first_level_dir.name
                    output_subdir.mkdir(exist_ok=True)
                    
                    # 复制tgz文件到输出目录
                    dst_file = output_subdir / item.name
                    if copy_file(item, dst_file):
                        copied_files.append(f"{first_level_dir.name}/{item.name}")
                        print(f"已复制现有包: {first_level_dir.name}/{item.name}")
            
            # 然后遍历二级子目录，查找包含Chart.yaml文件的目录
            for second_level_dir in first_level_dir.iterdir():
                if second_level_dir.is_dir() and (second_level_dir / "Chart.yaml").exists():
                    chart_dirs.append({
                        'chart_dir': second_level_dir,
                        'first_level_name': first_level_dir.name,
                        'chart_name': second_level_dir.name
                    })
    
    if not chart_dirs:
        print(f"警告: 在 {charts_dir} 目录中没有找到任何chart")
        return
    
    print(f"找到 {len(chart_dirs)} 个charts:")
    for chart_info in chart_dirs:
        print(f"  - {chart_info['first_level_name']}/{chart_info['chart_name']}")
    
    # 打包每个chart
    packaged_files = []
    for chart_info in chart_dirs:
        chart_dir = chart_info['chart_dir']
        first_level_name = chart_info['first_level_name']
        chart_name = chart_info['chart_name']
        
        print(f"\n正在打包 chart: {first_level_name}/{chart_name}")
        
        # Chart.yaml已经在上面的检查中确认存在
        chart_yaml = chart_dir / "Chart.yaml"
        
        # 创建对应的输出子目录
        output_subdir = output_path / first_level_name
        output_subdir.mkdir(exist_ok=True)
        
        # 执行helm package命令（使用相对路径）
        # 需要在一级目录下执行命令，并指定二级子目录作为打包目标
        relative_chart_path = f"{chart_name}"
        command = f"helm package {relative_chart_path} -d {output_subdir.absolute()}"
        run_command(command, cwd=chart_dir.parent)
        
        # 查找打包后的文件
        chart_version = get_chart_version(chart_yaml)
        if chart_version:
            packaged_file = f"{first_level_name}/{chart_name}-{chart_version}.tgz"
            packaged_files.append(packaged_file)
            print(f"成功打包: {packaged_file}")
    
    # 输出结果
    total_files = len(copied_files) + len(packaged_files)
    print(f"\n处理完成! 共处理了 {total_files} 个文件:")
    
    if copied_files:
        print(f"复制的现有包 ({len(copied_files)} 个):")
        for file in copied_files:
            print(f"  - {file}")
    
    if packaged_files:
        print(f"新打包的charts ({len(packaged_files)} 个):")
        for file in packaged_files:
            print(f"  - {file}")
    
    print(f"\n所有包已保存到: {output_path.absolute()}")

def get_chart_version(chart_yaml_path):
    """从Chart.yaml文件中获取chart版本"""
    try:
        with open(chart_yaml_path, 'r') as f:
            for line in f:
                if line.startswith('version:'):
                    return line.split(':')[1].strip()
    except Exception as e:
        print(f"读取Chart.yaml失败: {e}")
    return None

def main():
    """主函数"""
    print("开始打包Helm charts...")
    
    # 可以通过命令行参数指定charts目录和输出目录
    charts_dir = sys.argv[1] if len(sys.argv) > 1 else "charts"
    output_dir = sys.argv[2] if len(sys.argv) > 2 else "out"
    
    package_helm_charts(charts_dir, output_dir)

if __name__ == "__main__":
    main()