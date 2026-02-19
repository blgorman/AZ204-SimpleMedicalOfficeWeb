using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using SimpleMedicalOfficeWeb.Helpers;
using SimpleMedicalOfficeWeb.Models;
using SimpleMedicalOfficeWeb.Helpers;

namespace SimpleMedicalOfficeWeb.Controllers;

public class HomeController : Controller
{
    private readonly IConfiguration _configuration;
    public HomeController(IConfiguration configuration)
    {
        _configuration = configuration;
    }

    public IActionResult Index()
    {
        var storageAccountName = _configuration["StorageAccount:AccountName"] ?? string.Empty;
        var imagesContainerName = _configuration["StorageAccount:ImagesContainerName"] ?? string.Empty;
        var documentsContainerName = _configuration["StorageAccount:DocumentsContainerName"] ?? string.Empty;
        var storageAccountEndpoint = _configuration["StorageAccount:Endpoint"] ?? string.Empty;
        ViewData["StorageAccountName"] = storageAccountName;
        ViewData["ImagesContainerName"] = imagesContainerName;
        ViewData["DocumentsContainerName"] = documentsContainerName;
        ViewData["StorageAccountEndpoint"] = storageAccountEndpoint;

        var storageInteropInput = new StorageInteropInput(storageAccountEndpoint, storageAccountName
                                                            , imagesContainerName, documentsContainerName);
        var storageInterop = new StorageInterop(storageInteropInput);
        var imageDataUris = storageInterop.GetAllBlobsAsBase64DataUris(imagesContainerName);
        ViewData["ImageDataUris"] = imageDataUris;
        return View();
    }

    public IActionResult NewPatients()
    {
        var storageAccountName = _configuration["StorageAccount:AccountName"];
        var storageEndpoint = _configuration["StorageAccount:Endpoint"];
        var imagesContainerName = _configuration["StorageAccount:ImagesContainerName"];
        var documentsContainerName = _configuration["StorageAccount:DocumentsContainerName"];

        var storageInteropInput = new StorageInteropInput(storageEndpoint, storageAccountName
                                                            , imagesContainerName, documentsContainerName);
        var storageInterop = new StorageInterop(storageInteropInput);

        var blobNamesAndUris = storageInterop.GetAllBlobNamesAndUris(documentsContainerName);
        ViewData["BlobNames"] = blobNamesAndUris.Keys.ToList();

        return View();
    }

    public IActionResult DownloadDocument(string blobName)
    {
        if (string.IsNullOrWhiteSpace(blobName))
        {
            return BadRequest();
        }

        var storageAccountName = _configuration["StorageAccount:AccountName"];
        var storageEndpoint = _configuration["StorageAccount:Endpoint"];
        var imagesContainerName = _configuration["StorageAccount:ImagesContainerName"];
        var documentsContainerName = _configuration["StorageAccount:DocumentsContainerName"];

        var storageInteropInput = new StorageInteropInput(storageEndpoint, storageAccountName
                                                            , imagesContainerName, documentsContainerName);
        var storageInterop = new StorageInterop(storageInteropInput);

        var bytes = storageInterop.GetBlob(documentsContainerName, blobName);
        return File(bytes, "application/octet-stream", blobName);
    }

    public IActionResult Privacy()
    {
        return View();
    }

    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}
