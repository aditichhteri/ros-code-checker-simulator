#!/usr/bin/env python3
"""
Syntax Checker Module
Validates Python and C++ code syntax
"""

import subprocess
import os
from typing import List, Dict


def validate_python_syntax(filepath: str) -> List[Dict]:
    """
    Validate Python file syntax using flake8
    
    Args:
        filepath: Path to Python file
    
    Returns:
        List of error dictionaries
    """
    errors = []
    
    if not os.path.exists(filepath):
        return [{'file': filepath, 'error': 'File not found'}]
    
    try:
        # Run flake8
        result = subprocess.run(
            ['flake8', filepath, '--max-line-length=100'],
            capture_output=True,
            text=True,
            timeout=10
        )
        
        if result.returncode != 0:
            # Parse flake8 output
            for line in result.stdout.strip().split('\n'):
                if line:
                    parts = line.split(':')
                    if len(parts) >= 4:
                        errors.append({
                            'file': parts[0],
                            'line': parts[1],
                            'column': parts[2],
                            'error': ':'.join(parts[3:]).strip()
                        })
        
        print(f"[INFO] Checked {filepath}: {len(errors)} errors found")
        
    except subprocess.TimeoutExpired:
        errors.append({'file': filepath, 'error': 'Syntax check timed out'})
    except FileNotFoundError:
        errors.append({'file': filepath, 'error': 'flake8 not installed'})
    except Exception as e:
        errors.append({'file': filepath, 'error': f'Unexpected error: {str(e)}'})
    
    return errors


def validate_cpp_syntax(filepath: str) -> List[Dict]:
    """
    Validate C++ file syntax using g++ dry-run
    
    Args:
        filepath: Path to C++ file
    
    Returns:
        List of error dictionaries
    """
    errors = []
    
    if not os.path.exists(filepath):
        return [{'file': filepath, 'error': 'File not found'}]
    
    try:
        # Run g++ syntax check only (no linking)
        result = subprocess.run(
            ['g++', '-fsyntax-only', '-std=c++14', filepath],
            capture_output=True,
            text=True,
            timeout=10
        )
        
        if result.returncode != 0:
            # Parse g++ error output
            for line in result.stderr.strip().split('\n'):
                if 'error:' in line or 'warning:' in line:
                    errors.append({
                        'file': filepath,
                        'error': line.strip()
                    })
        
        print(f"[INFO] Checked {filepath}: {len(errors)} errors found")
        
    except subprocess.TimeoutExpired:
        errors.append({'file': filepath, 'error': 'Syntax check timed out'})
    except FileNotFoundError:
        errors.append({'file': filepath, 'error': 'g++ not installed'})
    except Exception as e:
        errors.append({'file': filepath, 'error': f'Unexpected error: {str(e)}'})
    
    return errors


if __name__ == '__main__':
    # Test the module
    import sys
    
    if len(sys.argv) < 2:
        print("Usage: python syntax_checker.py <file>")
        sys.exit(1)
    
    filepath = sys.argv[1]
    
    if filepath.endswith('.py'):
        errors = validate_python_syntax(filepath)
    elif filepath.endswith(('.cpp', '.h', '.hpp')):
        errors = validate_cpp_syntax(filepath)
    else:
        print("Unsupported file type")
        sys.exit(1)
    
    if errors:
        print(f"\nFound {len(errors)} errors:")
        for err in errors:
            print(f"  - {err}")
        sys.exit(1)
    else:
        print("\n✅ No syntax errors found")
        sys.exit(0)
