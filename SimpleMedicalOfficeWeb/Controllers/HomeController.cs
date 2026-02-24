using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SimpleMedicalOfficeWeb.Models;
using SimpleMedicalOfficeWeb.Helpers;
using SimpleMedicalOfficeWeb.Data;

namespace SimpleMedicalOfficeWeb.Controllers;

public class HomeController : Controller
{
    private readonly IConfiguration _configuration;
    private readonly ApplicationDbContext _context;
    
    public HomeController(IConfiguration configuration, ApplicationDbContext context)
    {
        _configuration = configuration;
        _context = context;
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

    public IActionResult Privacy()
    {
        return View();
    }

    public IActionResult NewPatients()
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

    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }

    public async Task<IActionResult> MigrateDatabase()
    {
        await _context.Database.MigrateAsync();
        return RedirectToAction(nameof(Index));
    }
}
