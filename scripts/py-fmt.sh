#!/bin/bash
source /opt/venv/bin/activate

yapf --style="{based_on_style: pep8, split_before_logical_operator: true, column_limit: 120, each_dict_entry_on_separate_line: true}" -i "$@"
