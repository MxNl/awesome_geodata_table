# Dynamic World in Google Earth Engine: most frequent class of summer 2023
import ee

ee.Initialize(project="<your-cloud-project>")
point = ee.Geometry.Point(13.40, 52.52)
dw = (
    ee.ImageCollection("GOOGLE/DYNAMICWORLD/V1")
    .filterDate("2023-06-01", "2023-09-01")
    .filterBounds(point)
)
label = dw.select("label").mode()  # 0 water ... 8 snow & ice
