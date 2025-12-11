# 🚀 Implementation Guide - ROS Code Checker & Simulation Tool

This guide provides complete implementation details with ready-to-use code for building the ROS Code Checker and Simulation Preview Tool.

## 📋 Table of Contents
1. [Backend - Code Checker](#backend---code-checker)
2. [Simulator - Gazebo Runner](#simulator---gazebo-runner)
3. [Web Interface - Flask App](#web-interface---flask-app)
4. [Test Packages](#test-packages)
5. [Setup Script](#setup-script)

---

## 1. Backend - Code Checker

### File: `backend/code_checker.py`

```python
#!/usr/bin/env python3
"""
Main Code Checker Module
Validates ROS packages for syntax, structure, and safety
"""

import os
import zipfile
import json
import tempfile
from pathlib import Path
from datetime import datetime

from syntax_checker import validate_python_syntax, validate_cpp_syntax
from ros_validator import validate_ros_structure, detect_ros_elements
from safety_checker import check_safety_heuristics
from report_generator import generate_report


class ROSCodeChecker:
    def __init__(self):
        self.results = {
            'timestamp': datetime.now().isoformat(),
            'package_name': None,
            'syntax_errors': [],
            'structure_errors': [],
            'safety_warnings': [],
            'ros_elements': {},
            'passed': False,
            'summary': {}
        }
    
    def extract_package(self, zip_path, extract_dir=None):
        """Extract ZIP package to temporary directory"""
        if extract_dir is None:
            extract_dir = tempfile.mkdtemp(prefix='ros_checker_')
        
        try:
            with zipfile.ZipFile(zip_path, 'r') as zip_ref:
                zip_ref.extractall(extract_dir)
            print(f"[INFO] Extracted package to {extract_dir}")
            return extract_dir
        except Exception as e:
            print(f"[ERROR] Failed to extract ZIP: {e}")
            return None
    
    def find_package_root(self, extract_dir):
        """Find the root directory containing package.xml"""
        for root, dirs, files in os.walk(extract_dir):
            if 'package.xml' in files:
                return root
        return extract_dir
    
    def check_package(self, zip_path, output_json=None):
        """Main validation function"""
        print("[INFO] Starting package validation...")
        
        # Extract package
        extract_dir = self.extract_package(zip_path)
        if not extract_dir:
            return None
        
        package_root = self.find_package_root(extract_dir)
        self.results['package_path'] = package_root
        
        # 1. Syntax validation
        print("[INFO] Checking syntax...")
        self.results['syntax_errors'] = self._check_syntax(package_root)
        
        # 2. ROS structure validation
        print("[INFO] Validating ROS structure...")
        structure_results = validate_ros_structure(package_root)
        self.results['structure_errors'] = structure_results['errors']
        self.results['package_name'] = structure_results.get('package_name', 'Unknown')
        
        # 3. Detect ROS elements
        print("[INFO] Detecting ROS elements...")
        self.results['ros_elements'] = self._detect_elements(package_root)
        
        # 4. Safety checks
        print("[INFO] Running safety checks...")
        self.results['safety_warnings'] = check_safety_heuristics(package_root)
        
        # Calculate pass/fail
        self.results['passed'] = (
            len(self.results['syntax_errors']) == 0 and
            len(self.results['structure_errors']) == 0
        )
        
        # Generate summary
        self.results['summary'] = {
            'total_errors': len(self.results['syntax_errors']) + len(self.results['structure_errors']),
            'total_warnings': len(self.results['safety_warnings']),
            'publishers': len(self.results['ros_elements'].get('publishers', [])),
            'subscribers': len(self.results['ros_elements'].get('subscribers', [])),
            'status': 'PASS' if self.results['passed'] else 'FAIL'
        }
        
        print(f"[INFO] Validation complete: {self.results['summary']['status']}")
        
        # Save to JSON if requested
        if output_json:
            with open(output_json, 'w') as f:
                json.dump(self.results, f, indent=2)
            print(f"[INFO] Report saved to {output_json}")
        
        return self.results
    
    def _check_syntax(self, package_root):
        """Check syntax for all Python and C++ files"""
        errors = []
        
        for root, dirs, files in os.walk(package_root):
            for file in files:
                filepath = os.path.join(root, file)
                
                if file.endswith('.py'):
                    py_errors = validate_python_syntax(filepath)
                    errors.extend(py_errors)
                
                elif file.endswith(('.cpp', '.h', '.hpp')):
                    cpp_errors = validate_cpp_syntax(filepath)
                    errors.extend(cpp_errors)
        
        return errors
    
    def _detect_elements(self, package_root):
        """Detect publishers, subscribers, services in Python files"""
        elements = {
            'publishers': [],
            'subscribers': [],
            'services': [],
            'nodes': []
        }
        
        for root, dirs, files in os.walk(package_root):
            for file in files:
                if file.endswith('.py'):
                    filepath = os.path.join(root, file)
                    file_elements = detect_ros_elements(filepath)
                    
                    elements['publishers'].extend(file_elements.get('publishers', []))
                    elements['subscribers'].extend(file_elements.get('subscribers', []))
                    elements['services'].extend(file_elements.get('services', []))
                    if file_elements.get('init_node'):
                        elements['nodes'].append(file)
        
        return elements


def main():
    import argparse
    
    parser = argparse.ArgumentParser(description='ROS Code Checker')
    parser.add_argument('--input', required=True, help='Path to ZIP file')
    parser.add_argument('--output', default='report.json', help='Output JSON report')
    
    args = parser.parse_args()
    
    checker = ROSCodeChecker()
    results = checker.check_package(args.input, args.output)
    
    if results and results['passed']:
        print("\n✅ Package validation PASSED")
        exit(0)
    else:
        print("\n❌ Package validation FAILED")
        exit(1)


if __name__ == '__main__':
    main()
```
