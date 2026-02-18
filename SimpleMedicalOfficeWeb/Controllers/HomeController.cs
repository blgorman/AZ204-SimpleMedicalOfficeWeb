using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
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
        var imagesContainerName = _configuration["StorageAccount:ImagesContainerName"];
        ViewData["StorageAccountName"] = storageAccountName;
        ViewData["ImagesContainerName"] = imagesContainerName;
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
