import os
os.environ['GDAL_DATA'] = r'D:\anaconda\envs\uav_rs\Library\share\gdal'
import geopandas as gpd

# 修改为你的shp文件路径
shp_path = r"D:\项目\无人机\20250323_DAP54\RGB\shp.lettuce2_numbered.shp"

gdf = gpd.read_file(shp_path)
print("矢量shp基本信息：")
print(f"多边形数量（植株数）：{len(gdf)}")
print(f"投影crs：{gdf.crs}")
print("\n字段列表：")
print(gdf.columns.tolist())
print("\n前5行PlotID：")
print(gdf[["PlotID"]].head())
