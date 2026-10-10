import os
os.environ['GDAL_DATA'] = r'D:\anaconda\envs\uav_rs\Library\share\gdal'
import geopandas as gpd

# =========使用你提供的真实完整路径=========
shp_path = r"D:\项目\无人机\20250323_DAP54\RGB\shp.lettuce2_numbered.shp"

# 1.读取原始shp（EPSG:4326）
gdf = gpd.read_file(shp_path)
print(f"原始shp投影：{gdf.crs}")

# 删除会报错的id字段
if "id" in gdf.columns:
    gdf = gdf.drop(columns=["id"])

# 2.投影转换，转为和影像一致 EPSG:32636
gdf_utm = gdf.to_crs(epsg=32636)
print(f"转换后shp投影：{gdf_utm.crs}")

# 3.抽样，只取前20株生菜做练习
gdf_sample = gdf_utm.head(20).copy()
print(f"抽样植株数量：{len(gdf_sample)}")
print("抽样PlotID列表：",gdf_sample['PlotID'].tolist())

# 4.保存转换投影后的抽样shp
out_shp = r"D:\项目\无人机\sample_20plants.shp"
gdf_sample.to_file(out_shp, encoding="utf-8")
print(f"已经输出抽样矢量文件：{out_shp}")
