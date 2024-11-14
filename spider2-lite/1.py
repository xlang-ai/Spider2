import os
import json
import random
import shutil

# 假设从文件中读取 JSONL 数据
jsonl_file = 'spider2-lite.jsonl'

# 读取 JSONL 数据并提取符合条件的 instance_id
instance_ids = []
prefixes = ('bq', 'ga', 'local', 'sf')

with open(jsonl_file, 'r') as f:
    for line in f:
        data = json.loads(line)
        instance_id = data['instance_id']
        if instance_id.startswith(prefixes):
            instance_ids.append(instance_id)

# 设置复制比例，例如 50%
ratio = 0.5
copy_count = int(len(instance_ids) * ratio)

# 随机选择要复制的 instance_id
selected_instance_ids = random.sample(instance_ids, copy_count)

# 定义源目录和目标目录
source_dir = '/Users/leifangyu/workspace/Spider2-C/evaluation_examples/source'
dest_dir = '/Users/leifangyu/workspace/release/Spider2/spider2-lite/evaluation_suite/gold/sql'

# 确保目标目录存在
os.makedirs(dest_dir, exist_ok=True)

# 复制文件
for instance_id in selected_instance_ids:
    sql_file = f'{instance_id}.sql'
    source_path = os.path.join(source_dir, instance_id, sql_file)
    if os.path.exists(source_path):
        shutil.copy(source_path, dest_dir)
        print(f'已复制 {source_path} 到 {dest_dir}')
    else:
        print(f'未找到对应的文件：{source_path}，跳过')