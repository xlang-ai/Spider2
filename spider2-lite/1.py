# import os
# import shutil

# # 定义源文件夹和目标文件夹
# source_folder = "/Users/leifangyu/workspace/release/Spider2/spider2-snow/resource/databases"
# target_folder = "/Users/leifangyu/workspace/release/Spider2/spider2-lite/resource/databases/snowflake"

# # 定义需要复制的数据库名称集合
# db_names = {'TCGA', 'ETHEREUM_BLOCKCHAIN', 'STACKOVERFLOW', 'HTAN_2', 'IOWA_LIQUOR_SALES', 'TCGA_HG19_DATA_V0', 
#             'GEO_OPENSTREETMAP_BOUNDARIES', 'CENSUS_BUREAU_ACS_2', 'WIDE_WORLD_IMPORTERS', 'NEW_YORK_CITIBIKE_1', 
#             'PYPI', 'TCGA_MITELMAN', 'DEATH', 'NOAA_PORTS', 'PANCANCER_ATLAS_1', 'CRYPTO', 'GITHUB_REPOS_DATE', 
#             'WORD_VECTORS_US', 'PATENTSVIEW', 'DEPS_DEV_V1', 'NOAA_DATA', 'HUMAN_GENOME_VARIANTS', 'TCGA_HG38_DATA_V0', 
#             'PATENTS_GOOGLE', 'AUSTIN', 'GEO_OPENSTREETMAP', 'NOAA_DATA_PLUS', 'GEO_OPENSTREETMAP_WORLDPOP', 
#             'THELOOK_ECOMMERCE', 'GITHUB_REPOS', 'SAN_FRANCISCO_PLUS', 'NOAA_GLOBAL_FORECAST_SYSTEM', 'IDC', 
#             'PATENTS', 'OPEN_TARGETS_GENETICS_2', 'GOOG_BLOCKCHAIN', 'GOOGLE_TRENDS', 'GOOGLE_ADS', 'PATENTS_USPTO', 
#             'META_KAGGLE', 'GEO_OPENSTREETMAP_CENSUS_PLACES'}

# # 创建目标文件夹
# os.makedirs(target_folder, exist_ok=True)

# # 遍历数据库名称集合并复制文件夹
# for db_name in db_names:
#     source_path = os.path.join(source_folder, db_name)
#     target_path = os.path.join(target_folder, db_name)
    
#     if os.path.exists(source_path):
#         shutil.copytree(source_path, target_path)
#         print(f"已复制 {source_path} 到 {target_path}")
#     else:
#         print(f"源文件夹 {source_path} 不存在")

# print("所有数据库文件夹已复制完成。")




import os
import json
import shutil

# 定义文件路径
jsonl_file_path = "/Users/leifangyu/workspace/Spider2-C/Spider2-SQL/spider2-lite_updated.jsonl"
bigquery_folder = "/Users/leifangyu/workspace/release/Spider2/spider2-lite/resource/databases/bigquery"

# 初始化一个set来存储db字段
db_set = set()

# 读取jsonl文件并提取以bq开头的instance_id的db字段
with open(jsonl_file_path, 'r') as file:
    for line in file:
        data = json.loads(line)
        if data.get('instance_id', '').startswith('bq'):
            db_set.add(data.get('db', '').lower())

# 遍历bigquery文件夹的子文件夹
for subdir in os.listdir(bigquery_folder):
    subdir_path = os.path.join(bigquery_folder, subdir)
    if os.path.isdir(subdir_path) and subdir.lower() not in db_set:
        shutil.rmtree(subdir_path)
        print(f"已删除文件夹 {subdir_path}")

print("不在set中的子文件夹已删除。")