# BookApi

All URIs are relative to *https://swaggerhub.mwhiggins.com/virts/SmartBear_Org/Book/1.1.0*

Method | HTTP request | Description
------------- | ------------- | -------------
[**a12125**](BookApi.md#a12125) | **GET** /book | 

<a name="a12125"></a>
# **a12125**
> InlineResponse200 a12125()



List the books

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
    InlineResponse200 result = apiInstance.a12125();
    System.out.println(result);
} catch (ApiException e) {
    System.err.println("Exception when calling BookApi#a12125");
    e.printStackTrace();
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**InlineResponse200**](InlineResponse200.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

