#!/usr/bin/env python3
"""
Helm部署脚本
支持template和install两个命令，根据deployment-config.yaml配置文件执行相应的helm操作
"""

import yaml
import argparse
import subprocess
import sys
import os
from typing import Dict, List, Any, Optional


class HelmDeployer:
    """Helm部署器类"""
    
    def __init__(self, config_file: str = "deployment-config.yaml", chart_base_dir: str = "./charts", output_dir: str = "./output"):
        """
        初始化Helm部署器
        
        Args:
            config_file: 配置文件路径
            chart_base_dir: chart基础目录路径
            output_dir: template命令输出目录
        """
        self.config_file = config_file
        self.chart_base_dir = chart_base_dir
        self.output_dir = output_dir
        self.config = self._load_config()
        self.successful_projects = []
        self.failed_projects = []
    
    def _load_config(self) -> Dict[str, Any]:
        """
        加载配置文件
        
        Returns:
            配置字典
        """
        try:
            with open(self.config_file, 'r', encoding='utf-8') as f:
                return yaml.safe_load(f)
        except FileNotFoundError:
            print(f"错误: 配置文件 {self.config_file} 不存在")
            sys.exit(1)
        except yaml.YAMLError as e:
            print(f"错误: 配置文件格式错误: {e}")
            sys.exit(1)
    
    def _get_namespace(self, section_config: Dict[str, Any]) -> str:
        """
        获取命名空间
        
        Args:
            section_config: 配置段字典
            
        Returns:
            命名空间名称
        """
        # 优先使用section中的namespace
        if 'namespace' in section_config and section_config['namespace']:
            namespace = section_config['namespace']
            if namespace is None:
                namespace = ""
            return namespace if namespace else "default"
        
        # 其次使用global中的namespace
        if 'global' in self.config and 'namespace' in self.config['global']:
            namespace = self.config['global']['namespace']
            if namespace is None:
                namespace = ""
            return namespace if namespace else "default"
        
        # 默认命名空间
        return "default"
    
    def _build_helm_command(self, command: str, section_name: str, subsection_name: str, 
                           config: Dict[str, Any]) -> List[str]:
        """
        构建helm命令
        
        Args:
            command: helm命令类型 (template/install)
            section_name: 配置段名称
            subsection_name: 子配置段名称
            config: 配置字典
            
        Returns:
            helm命令列表
        """
        helm_cmd = ["helm", command]
        
        # 添加release名称
        release_name = subsection_name
        helm_cmd.append(release_name)
        
        # 添加chart路径
        if 'chart' not in config:
            print(f"警告: {section_name}.{subsection_name} 缺少chart配置，跳过")
            return None
        
        chart_path = f"{self.chart_base_dir}/{section_name}/{config['chart']}"
        helm_cmd.append(chart_path)
        
        # 添加命名空间
        namespace = self._get_namespace(config)
        helm_cmd.extend(["-n", namespace])
        
        # 如果是template命令，添加输出目录
        if command == "template":
            output_path = f"{self.output_dir}/{section_name}/{subsection_name}"
            helm_cmd.extend(["--output-dir", output_path])
        
        # 添加values文件
        if 'values' in config and config['values']:
            values_path = f"values/{section_name}/{config['values']}"
            if os.path.exists(values_path):
                helm_cmd.extend(["-f", values_path])
            else:
                print(f"警告: values文件 {values_path} 不存在，跳过")
        
        # 添加全局set参数
        if 'global' in self.config and 'set' in self.config['global'] and self.config['global']['set']:
            global_set = self.config['global']['set']
            if isinstance(global_set, str):
                # 如果是字符串，按逗号分割
                for set_item in global_set.split(','):
                    set_item = set_item.strip()
                    if set_item:  # 跳过空字符串
                        helm_cmd.extend(["--set", set_item])
            elif isinstance(global_set, list):
                # 如果是列表，直接处理
                for set_item in global_set:
                    if set_item:  # 跳过空字符串
                        helm_cmd.extend(["--set", set_item])
        
        # 添加当前配置的set参数
        if 'set' in config and config['set']:
            set_config = config['set']
            if isinstance(set_config, dict):
                # 如果是字典，遍历所有键值对
                for key, value in set_config.items():
                    if key and value is not None:  # 跳过空键或空值
                        helm_cmd.extend(["--set", f"{key}={value}"])
            elif isinstance(set_config, list):
                # 如果是列表，直接处理
                for set_item in set_config:
                    if set_item:  # 跳过空字符串
                        helm_cmd.extend(["--set", set_item])
            elif isinstance(set_config, str):
                # 如果是字符串，按逗号分割
                for set_item in set_config.split(','):
                    set_item = set_item.strip()
                    if set_item:  # 跳过空字符串
                        helm_cmd.extend(["--set", set_item])
        
        # 添加当前配置的storageClass参数
        if 'storageClass' in config and config['storageClass']:
            storage_class = config['storageClass']
            if isinstance(storage_class, dict):
                # 如果是字典，遍历所有键值对
                for key, value in storage_class.items():
                    if key and value is not None:  # 跳过空键或空值
                        helm_cmd.extend(["--set", f"{key}={value}"])
        
        return helm_cmd
    
    def _execute_helm_command(self, command: List[str]) -> bool:
        """
        执行helm命令
        
        Args:
            command: helm命令列表
            
        Returns:
            执行是否成功
        """
        try:
            print(f"执行命令: {' '.join(command)}")
            result = subprocess.run(command, check=True, capture_output=True, text=True)
            if result.stdout:
                print(result.stdout)
            return True
        except subprocess.CalledProcessError as e:
            print(f"命令执行失败: {e}")
            if e.stderr:
                print(f"错误输出: {e.stderr}")
            return False
        except FileNotFoundError:
            print("错误: helm命令未找到，请确保helm已安装并在PATH中")
            return False
    
    def process_section(self, command: str, section_name: str, section_config: Dict[str, Any]) -> bool:
        """
        处理配置段
        
        Args:
            command: helm命令类型
            section_name: 配置段名称
            section_config: 配置段字典
            
        Returns:
            处理是否成功
        """
        success = True
        
        for subsection_name, subsection_config in section_config.items():
            if subsection_name == 'namespace':  # 跳过namespace字段
                continue
                
            if isinstance(subsection_config, dict):
                helm_cmd = self._build_helm_command(command, section_name, subsection_name, subsection_config)
                if helm_cmd is None:
                    success = False
                    self.failed_projects.append(f"{section_name}.{subsection_name}")
                    continue
                if not self._execute_helm_command(helm_cmd):
                    success = False
                    self.failed_projects.append(f"{section_name}.{subsection_name}")
                else:
                    self.successful_projects.append(f"{section_name}.{subsection_name}")
            else:
                print(f"警告: {section_name}.{subsection_name} 配置格式不正确，跳过")
                self.failed_projects.append(f"{section_name}.{subsection_name}")
                success = False
        
        return success
    
    def run_template(self) -> bool:
        """
        运行template命令
        
        Returns:
            执行是否成功
        """
        print("开始执行helm template命令...")
        success = True
        
        # 清空项目列表
        self.successful_projects = []
        self.failed_projects = []
        
        for section_name, section_config in self.config.items():
            if section_name == 'global':  # 跳过global段
                continue
                
            if isinstance(section_config, dict):
                print(f"\n处理配置段: {section_name}")
                if not self.process_section('template', section_name, section_config):
                    success = False
            else:
                print(f"警告: 配置段 {section_name} 格式不正确，跳过")
        
        # 输出总结
        print("\n" + "="*50)
        print("执行总结")
        print("="*50)
        print(f"成功项目数量: {len(self.successful_projects)}")
        if self.successful_projects:
            print("成功项目:")
            for project in self.successful_projects:
                print(f"  ✓ {project}")
        
        print(f"\n失败项目数量: {len(self.failed_projects)}")
        if self.failed_projects:
            print("失败项目:")
            for project in self.failed_projects:
                print(f"  ✗ {project}")
        
        print("="*50)
        
        return success
    
    def run_install(self) -> bool:
        """
        运行install命令
        
        Returns:
            执行是否成功
        """
        print("开始执行helm install命令...")
        success = True
        
        # 清空项目列表
        self.successful_projects = []
        self.failed_projects = []
        
        for section_name, section_config in self.config.items():
            if section_name == 'global':  # 跳过global段
                continue
                
            if isinstance(section_config, dict):
                print(f"\n处理配置段: {section_name}")
                if not self.process_section('install', section_name, section_config):
                    success = False
            else:
                print(f"警告: 配置段 {section_name} 格式不正确，跳过")
        
        # 输出总结
        print("\n" + "="*50)
        print("执行总结")
        print("="*50)
        print(f"成功项目数量: {len(self.successful_projects)}")
        if self.successful_projects:
            print("成功项目:")
            for project in self.successful_projects:
                print(f"  ✓ {project}")
        
        print(f"\n失败项目数量: {len(self.failed_projects)}")
        if self.failed_projects:
            print("失败项目:")
            for project in self.failed_projects:
                print(f"  ✗ {project}")
        
        print("="*50)
        
        return success
    
    def run_upgrade(self) -> bool:
        """
        运行upgrade命令
        
        Returns:
            执行是否成功
        """
        print("开始执行helm upgrade命令...")
        success = True
        
        # 清空项目列表
        self.successful_projects = []
        self.failed_projects = []
        
        for section_name, section_config in self.config.items():
            if section_name == 'global':  # 跳过global段
                continue
                
            if isinstance(section_config, dict):
                print(f"\n处理配置段: {section_name}")
                if not self.process_section('upgrade', section_name, section_config):
                    success = False
            else:
                print(f"警告: 配置段 {section_name} 格式不正确，跳过")
        
        # 输出总结
        print("\n" + "="*50)
        print("执行总结")
        print("="*50)
        print(f"成功项目数量: {len(self.successful_projects)}")
        if self.successful_projects:
            print("成功项目:")
            for project in self.successful_projects:
                print(f"  ✓ {project}")
        
        print(f"\n失败项目数量: {len(self.failed_projects)}")
        if self.failed_projects:
            print("失败项目:")
            for project in self.failed_projects:
                print(f"  ✗ {project}")
        
        print("="*50)
        
        return success
    
    def run_check(self) -> bool:
        """
        运行check命令，检查tgz文件和values文件是否存在
        
        Returns:
            检查是否成功
        """
        print("开始检查文件...")
        success = True
        
        for section_name, section_config in self.config.items():
            if section_name == 'global':  # 跳过global段
                continue
                
            if isinstance(section_config, dict):
                print(f"\n检查配置段: {section_name}")
                if not self._check_section_files(section_name, section_config):
                    success = False
            else:
                print(f"警告: 配置段 {section_name} 格式不正确，跳过")
        
        return success
    
    def _check_section_files(self, section_name: str, section_config: Dict[str, Any]) -> bool:
        """
        检查配置段中的文件是否存在
        
        Args:
            section_name: 配置段名称
            section_config: 配置段字典
            
        Returns:
            检查是否成功
        """
        success = True
        
        for subsection_name, subsection_config in section_config.items():
            if subsection_name == 'namespace':  # 跳过namespace字段
                continue
                
            if isinstance(subsection_config, dict):
                # 检查chart文件
                if 'chart' in subsection_config:
                    chart_path = f"{self.chart_base_dir}/{section_name}/{subsection_config['chart']}"
                    if os.path.exists(chart_path):
                        print(f"✓ {section_name}.{subsection_name} chart文件存在: {chart_path}")
                    else:
                        print(f"✗ {section_name}.{subsection_name} chart文件不存在: {chart_path}")
                        success = False
                else:
                    print(f"警告: {section_name}.{subsection_name} 缺少chart配置")
                    success = False
                
                # 检查values文件
                if 'values' in subsection_config and subsection_config['values']:
                    values_path = f"values/{section_name}/{subsection_config['values']}"
                    if os.path.exists(values_path):
                        print(f"✓ {section_name}.{subsection_name} values文件存在: {values_path}")
                    else:
                        print(f"✗ {section_name}.{subsection_name} values文件不存在: {values_path}")
                        success = False
            else:
                print(f"警告: {section_name}.{subsection_name} 配置格式不正确，跳过")
        
        return success


def main():
    """主函数"""
    parser = argparse.ArgumentParser(description="Helm部署脚本")
    parser.add_argument("command", choices=["template", "install", "upgrade", "check"],
                       help="要执行的helm命令")
    parser.add_argument("--config", default="deployment-config.yaml",
                       help="配置文件路径 (默认: deployment-config.yaml)")
    parser.add_argument("--chart-base-dir", default="./out",
                       help="chart基础目录路径 (默认: ./out)")
    parser.add_argument("--output-dir", default="./output",
                       help="template命令输出目录 (默认: ./output)")
    
    args = parser.parse_args()
    
    # 检查配置文件是否存在
    if not os.path.exists(args.config):
        print(f"错误: 配置文件 {args.config} 不存在")
        sys.exit(1)
    
    # 创建部署器实例
    deployer = HelmDeployer(args.config, args.chart_base_dir, args.output_dir)
    
    # 执行相应命令
    if args.command == "template":
        success = deployer.run_template()
    elif args.command == "install":
        success = deployer.run_install()
    elif args.command == "upgrade":
        success = deployer.run_upgrade()
    elif args.command == "check":
        success = deployer.run_check()
    
    # 根据执行结果退出
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()