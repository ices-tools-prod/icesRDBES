# icesRDBES 0.0.9 (2025-06-18)

* Modified rdbes_upload_data() so that a screening report is downloaded and user needs to confirm if
  data will be deleted by upload.
* Added documentation on how to dowload CEF data.
* Added package version to API GET request to request user to update icesRDBES package if version is not high enough.
* Package version now quoted in package load message.

# icesRDBES 0.0.8 (2025-05-13)

* Added functions to upload data: upload_rdbes_data()
* Modified rdbes_api() to request url for upload and download seperately

# icesRDBES 0.0.7 (2025-04-13)

* Initial package with download function download_rdbes_data()
* Can switch root url of api between sandbox and production using the use_sboxrdbes() function
