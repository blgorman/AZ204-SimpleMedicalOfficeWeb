namespace SimpleMedicalOfficeWeb.Data;

public interface IUserRolesService
{
    Task EnsureAdminUserRole();
}
