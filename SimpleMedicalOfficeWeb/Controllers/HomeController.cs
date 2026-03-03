using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SimpleMedicalOfficeWeb.Models;
using SimpleMedicalOfficeWeb.Helpers;
using SimpleMedicalOfficeWeb.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.ApplicationInsights;

namespace SimpleMedicalOfficeWeb.Controllers;
public class HomeController : Controller
{
    private readonly IConfiguration _configuration;
    private readonly ApplicationDbContext _context;
    private readonly IUserRolesService _userRolesService;
    private readonly TelemetryClient _telemetry;

    public HomeController(IConfiguration configuration
                            , ApplicationDbContext context
                            , IUserRolesService userRolesService
                            , TelemetryClient telemetry)
    {
        _configuration = configuration;
        _context = context;
        _userRolesService = userRolesService;
        _telemetry = telemetry;
    }

    public IActionResult Index()
    {
        _telemetry.TrackEvent("VisitedHomePage");

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
        var output = $"Image Data URIs: {string.Join('|', imageDataUris)}";
        ViewData["ImageDataUris"] = imageDataUris;

        _telemetry.TrackTrace(output);
        return View();
    }

    public IActionResult Privacy()
    {
        return View();
    }

    public IActionResult SimulatedException()
    {
        int x = 10;
        int y = 10;
        try
        {
            int z = (x + y) / (10 - y);
            throw new ArgumentException("I simulated an exception for testing purposes.");
        }
        catch (Exception ex)
        {
            _telemetry.TrackException(ex);
        }
        return RedirectToAction("Index");
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

    //make sure we have the admin user and role created
    //so we can test role-based auth in the app
    public async Task<IActionResult> EnsureAdminUserRole()
    {
        await _userRolesService.EnsureAdminUserRole();
        return RedirectToAction(nameof(Index));
    }
}
