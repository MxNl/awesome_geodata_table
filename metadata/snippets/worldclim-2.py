# WorldClim 2.1 monthly precipitation normals (1970-2000), 10 arc-minutes
import urllib.request
import zipfile

url = "https://geodata.ucdavis.edu/climate/worldclim/2_1/base/wc2.1_10m_prec.zip"
path, _ = urllib.request.urlretrieve(url, "wc2.1_10m_prec.zip")
zipfile.ZipFile(path).extractall("worldclim")
