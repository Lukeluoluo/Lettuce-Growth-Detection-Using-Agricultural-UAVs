import os
os.environ['GDAL_DATA'] = r'D:\anaconda\envs\uav_rs\Library\share\gdal'
import rasterio

# ========== 修改为你本机实际tif路径 ==========
rgb_tif_path = r"D:\项目\无人机\20250323_DAP54\RGB\RGB_DJI_202503241214_038_30m_CUT.tif"
multi_tif_path = r"D:\项目\无人机\20250323_DAP54\MULTI\MULTI_202503241214_038_30m_CUT.tif"
print("===== 【RGB影像元数据】 =====")
with rasterio.open(rgb_tif_path) as src:
    print(f"宽width：{src.width}，高height：{src.height}")
    print(f"波段总数count：{src.count}")
    print(f"波段描述descriptions：{src.descriptions}")
    print(f"投影CRS：{src.crs}")
    print(f"像素分辨率(px_x,px_y)：{src.res}")
    print(f"Nodata值：{src.nodata}")

print("\n===== 【多光谱MULTI影像元数据】 =====")
with rasterio.open(multi_tif_path) as src:
    print(f"宽width：{src.width}，高height：{src.height}")
    print(f"波段总数count：{src.count}")
    print(f"波段描述descriptions：{src.descriptions}")
    print(f"投影CRS：{src.crs}")
    print(f"像素分辨率(px_x,px_y)：{src.res}")
    print(f"Nodata值：{src.nodata}")
