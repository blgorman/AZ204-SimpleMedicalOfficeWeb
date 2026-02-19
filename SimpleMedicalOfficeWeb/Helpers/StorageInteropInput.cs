namespace SimpleMedicalOfficeWeb.Helpers;

public class StorageInteropInput
{
    public string StorageEndpoint { get; set; } = string.Empty;
    public string AccountName { get; set; } = string.Empty;
    public string ImagesContainerName { get; set; } = string.Empty;
    public string DocumentsContainerName { get; set; } = string.Empty;

    public StorageInteropInput()
    {
        
    }

    public StorageInteropInput(string storageEndpoint, string accountName
                                , string imagesContainerName, string documentsContainerName)
    {
        AccountName = accountName;
        ImagesContainerName = imagesContainerName;
        DocumentsContainerName = documentsContainerName;
        StorageEndpoint = storageEndpoint;
    }
}
