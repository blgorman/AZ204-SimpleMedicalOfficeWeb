using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using SimpleMedicalOfficeWeb.Helpers;
using SimpleMedicalOfficeWeb.Models;

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
        var storageAccountName = _configuration["StorageAccount:AccountName"];
        var storageEndpoint = _configuration["StorageAccount:Endpoint"];
        var imagesContainerName = _configuration["StorageAccount:ImagesContainerName"];
        var documentsContainerName = _configuration["StorageAccount:DocumentsContainerName"];
        ViewData["StorageAccountName"] = storageAccountName;
        ViewData["ImagesContainerName"] = imagesContainerName;
        ViewData["DocumentsContainerName"] = documentsContainerName;

        //get the images from the images container
        var storageInteropInput = new StorageInteropInput(storageEndpoint, storageAccountName
                                                            , imagesContainerName, documentsContainerName);
        var storageInterop = new StorageInterop(storageInteropInput);

        var imageDataUris = storageInterop.GetAllBlobsAsBase64DataUris(imagesContainerName);
        ViewData["ImageDataUris"] = imageDataUris;

        return View();
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
