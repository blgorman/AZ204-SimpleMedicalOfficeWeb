namespace SimpleMedicalOfficeWeb.Helpers;

public class StorageInteropInput
{
    public string StorageEndpoint { get; set; }
    public string AccountName { get; set; }
    public string ImagesContainerName { get; set; }
    public string DocumentsContainerName { get; set; }

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
