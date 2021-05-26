# BookApi

All URIs are relative to *https://swaggerhub.mwhiggins.com/virts/SmartBear_Org/Book/1.1.0*

Method | HTTP request | Description
------------- | ------------- | -------------
[**bookGet**](BookApi.md#bookGet) | **GET** /book | 

<a name="bookGet"></a>
# **bookGet**
> BookSuccess bookGet()



List the books.

### Example
```java
// Import classes:
//import io.swagger.client.ApiClient;
//import io.swagger.client.ApiException;
//import io.swagger.client.Configuration;
//import io.swagger.client.auth.*;
//import io.swagger.client.api.BookApi;

ApiClient defaultClient = Configuration.getDefaultApiClient();


BookApi apiInstance = new BookApi();
try {
    BookSuccess result = apiInstance.bookGet();
    System.out.println(result);
} catch (ApiException e) {
    System.err.println("Exception when calling BookApi#bookGet");
    e.printStackTrace();
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BookSuccess**](BookSuccess.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

