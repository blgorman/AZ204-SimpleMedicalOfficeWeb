using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace SimpleMedicalOfficeWeb.Controllers;

[Authorize(Roles ="Admin")]
public class InsuranceController : Controller
{
    public IActionResult Index()
    {
        return View();
    }

    public IActionResult Details(int id)
    {
        return View(id);
    }

    public IActionResult Update(int id)
    {
        return View(id);
    }
}
