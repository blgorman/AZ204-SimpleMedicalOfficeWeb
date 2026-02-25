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

    private BlobServiceClient GetBlobServiceClient()
    {
        DefaultAzureCredential credential = new DefaultAzureCredential();
        var endpointURI = new Uri(_input.StorageEndpoint);
        return new BlobServiceClient(endpointURI, credential);
    }

    private BlobContainerClient GetBlobContainerClient(string containerName)
    {
        var _blobServiceClient = GetBlobServiceClient();
        var containerClient = _blobServiceClient.GetBlobContainerClient(containerName);
        if (containerClient == null || !containerClient.Exists())
        {
            throw new Exception($"Container {containerName} not found!");
        }
        return containerClient;
    }

    private BlobClient GetBlobClient(string containerName, string blobName)
    {
        var containerClient = GetBlobContainerClient(containerName);
        var target = containerClient.GetBlobClient(blobName);
        if (target == null || !target.Exists())
        {
            throw new Exception($"Blob {blobName} not found in container {containerName}");
        }
        return target;
    }

    public byte[] GetBlob(string containerName, string blobName)
    {
        try
        {
            var blobClient = GetBlobClient(containerName, blobName);

            using (var ms = new MemoryStream())
            {
                blobClient.DownloadTo(ms);
                return ms.ToArray();
            }
        }
        catch (Exception ex)
        {
            //todo: Stop swallowing exceptions, log them instead
            throw new FileNotFoundException("Could not get blob");
        }
    }

    public List<string> GetAllBlobsAsBase64DataUris(string containerName)
    {
        try
        {
            var containerClient = GetBlobContainerClient(containerName);
            var dataUris = new List<string>();
            foreach (var blobItem in containerClient.GetBlobs())
            {
                var blobClient = containerClient.GetBlobClient(blobItem.Name);
                var properties = blobClient.GetProperties();
                var contentType = properties.Value.ContentType ?? "application/octet-stream";

                if (!contentType.StartsWith("image/", StringComparison.OrdinalIgnoreCase))
                {
                    continue;
                }

                using var ms = new MemoryStream();
                blobClient.DownloadTo(ms);
                var base64 = Convert.ToBase64String(ms.ToArray());
                dataUris.Add($"data:{contentType};base64,{base64}");
            }
            return dataUris;
        }
        catch (Exception ex)
        {
            //todo: Stop swallowing exceptions, log them instead
             
        }
        return new List<string>();
    }

    public void UploadBlob(string containerName, string blobName, Stream content)
    {
        try
        {
            var target = GetBlobClient(containerName, blobName);
            target.Upload(content);
        }
        catch (Exception ex)
        {
            //TODO: log exception
            throw new Exception("Can't upload blob at this time");
        }

    }

    public Dictionary<string, string> GetAllBlobNamesAndUris(string containerName)
    {
        var blobMap = new Dictionary<string, string>();
        try
        {
            var blobServiceClient = GetBlobServiceClient();
            var containerClient = blobServiceClient.GetBlobContainerClient(containerName);
            
            foreach (var blobItem in containerClient.GetBlobs())
            {
                var blobClient = containerClient.GetBlobClient(blobItem.Name);
                blobMap[blobItem.Name] = blobClient.Uri.ToString();
            }
        }
        catch (System.Exception ex)
        {
            //TODO: log exception
        }
        return blobMap;
    }
}
