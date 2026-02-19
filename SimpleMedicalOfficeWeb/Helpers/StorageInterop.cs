using Azure.Identity;
using Azure.Storage.Blobs;

namespace SimpleMedicalOfficeWeb.Helpers;

public class StorageInterop
{
    private readonly StorageInteropInput _input;

    public StorageInterop(StorageInteropInput input)
    {
        if (string.IsNullOrWhiteSpace(input.AccountName)
            || string.IsNullOrWhiteSpace(input.DocumentsContainerName)
            || string.IsNullOrWhiteSpace(input.ImagesContainerName)
            || string.IsNullOrWhiteSpace(input.StorageEndpoint))
        { 
            throw new ArgumentNullException($"Please provide account name, images container name, and documents container name");
        }

        _input = input;
    }

    public BlobServiceClient GetBlobServiceClient()
    {
        // Create a DefaultAzureCredentialOptions object to configure the DefaultAzureCredential
        DefaultAzureCredentialOptions options = new()
        {
            ExcludeEnvironmentCredential = true,
            ExcludeManagedIdentityCredential = true
        };
        DefaultAzureCredential credential = new DefaultAzureCredential(options);
        var endpointURI = new Uri(_input.StorageEndpoint);
        return new BlobServiceClient(endpointURI, credential);
    }

    public byte[] GetBlob(string containerName, string blobName)
    {
        //get the specific container into a client
        var blobClient = GetBlobClient(containerName, blobName);

        using (var ms = new MemoryStream())
        {
            blobClient.DownloadTo(ms);
            return ms.ToArray();
        }
    }

    public BlobClient GetBlobClient(string containerName, string blobName)
    {
        var _blobServiceClient = GetBlobServiceClient();
        var containerClient = _blobServiceClient.GetBlobContainerClient(containerName);
        if (containerClient == null)
        {
            throw new Exception($"Container {containerName} not found!");
        }
        var target = containerClient.GetBlobClient(blobName);
        if (target == null || !target.Exists())
        {
            throw new Exception($"Blob {blobName} not found in container {containerName}");
        }
        return target;
    }

    public void UploadBlob(string containerName, string blobName, Stream content)
    {
        var target = GetBlobClient(containerName, blobName);
        target.Upload(content, overwrite: true);
    }

    public List<string> GetAllBlobUris(string containerName)
    {
        var blobServiceClient = GetBlobServiceClient();
        var containerClient = blobServiceClient.GetBlobContainerClient(containerName);
        var blobUris = new List<string>();
        foreach (var blobItem in containerClient.GetBlobs())
        {
            var blobClient = containerClient.GetBlobClient(blobItem.Name);
            blobUris.Add(blobClient.Uri.ToString());
        }
        return blobUris;
    }

    public List<string> GetAllBlobsAsBase64DataUris(string containerName)
    {
        var blobServiceClient = GetBlobServiceClient();
        var containerClient = blobServiceClient.GetBlobContainerClient(containerName);
        var dataUris = new List<string>();
        foreach (var blobItem in containerClient.GetBlobs())
        {
            var blobClient = containerClient.GetBlobClient(blobItem.Name);
            var properties = blobClient.GetProperties();
            var contentType = properties.Value.ContentType ?? "application/octet-stream";

            using var ms = new MemoryStream();
            blobClient.DownloadTo(ms);
            var base64 = Convert.ToBase64String(ms.ToArray());
            dataUris.Add($"data:{contentType};base64,{base64}");
        }
        return dataUris;
    }
}
