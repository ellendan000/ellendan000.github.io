---
title: Java S3 Example
date: 2016-06-24 21:41:00  
tags: 
    - AWS
    - Java
categories: 
    - AWS
    - Java
---

最近听了一次亮哥他们AWS的首次session，中间稍微提到了一下IAM account的access key。没想到在项目中给别人code review的时候就接触到了，是针对AWS S3的。具体S3说明，见 http://aws.amazon.com/s3/

---

## Setting up project

1\. AWS SDK for Java

```xml
<dependency>
    <groupId>com.amazonaws</groupId>
    <artifactId>aws-java-sdk</artifactId>
    <version>1.9.2</version>
</dependency>
```

2\. 使用一个IAM account，如果没有创建一个，获取到它的“Access key”和“Secret Access Key”。

## Authenticate with Amazon S3

1\. 使用Access Key进行验证

1） 环境变量Environment Variables – AWS\_ACCESS\_KEY\_ID and AWS\_SECRET\_ACCESS\_KEY.

2） Java System Properties – aws.accessKeyId and aws.secretKey.

3） 默认用户下profiles文件， ~/.aws/credentials

```markdown
[default]
aws_access_key_id={YOUR_ACCESS_KEY_ID}
aws_secret_access_key={YOUR_SECRET_ACCESS_KEY}

[profile2]
...
```

4） 代码中直接填写

前三种使用验证链：

```java
AmazonS3 s3Client = new AmazonS3Client();

//or
//The following line of code is effectively equivalent to the preceding example:
AmazonS3 s3Client = new AmazonS3Client(new DefaultAWSCredentialsProviderChain());
```

第四种：

```java
AWSCredentials credentials = new BasicAWSCredentials("YourAccessKeyID", "YourSecretAccessKey");
AmazonS3 s3client = new AmazonS3Client(credentials);
```

2\. 从AWS Security Token Service ([AWS STS](http://aws.amazon.com/documentation/iam/)) 获取临时证书，见[Document](http://docs.aws.amazon.com/AWSSdkDocsJava/latest/DeveloperGuide/prog-services-sts.html?highlight=awssecuritytokenserviceclient)

## SDK Example

```java
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.InputStream;
import java.util.List;

import com.amazonaws.auth.AWSCredentials;
import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3Client;
import com.amazonaws.services.s3.model.Bucket;
import com.amazonaws.services.s3.model.CannedAccessControlList;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.PutObjectRequest;
import com.amazonaws.services.s3.model.S3ObjectSummary;

public class AmazonS3Example {
	
	private static final String SUFFIX = "/";
	
	public static void main(String[] args) {
		// credentials object identifying user for authentication
		// user must have AWSConnector and AmazonS3FullAccess for 
		// this example to work
		AWSCredentials credentials = new BasicAWSCredentials(
				"YourAccessKeyID", 
				"YourSecretAccessKey");
		
		// create a client connection based on credentials
		AmazonS3 s3client = new AmazonS3Client(credentials);
		
		// create bucket - name must be unique for all S3 users
		String bucketName = "javatutorial-net-example-bucket";
		s3client.createBucket(bucketName);
		
		// list buckets
		for (Bucket bucket : s3client.listBuckets()) {
			System.out.println(" - " + bucket.getName());
		}
		
		// create folder into bucket
		String folderName = "testfolder";
		createFolder(bucketName, folderName, s3client);
		
		// upload file to folder and set it to public
		String fileName = folderName + SUFFIX + "testvideo.mp4";
		s3client.putObject(new PutObjectRequest(bucketName, fileName, 
				new File("C:\\Users\\user\\Desktop\\testvideo.mp4"))
				.withCannedAcl(CannedAccessControlList.PublicRead));
		
		deleteFolder(bucketName, folderName, s3client);
		
		// deletes bucket
		s3client.deleteBucket(bucketName);
	}
	
	public static void createFolder(String bucketName, String folderName, AmazonS3 client) {
		// create meta-data for your folder and set content-length to 0
		ObjectMetadata metadata = new ObjectMetadata();
		metadata.setContentLength(0);

		// create empty content
		InputStream emptyContent = new ByteArrayInputStream(new byte[0]);

		// create a PutObjectRequest passing the folder name suffixed by /
		PutObjectRequest putObjectRequest = new PutObjectRequest(bucketName,
				folderName + SUFFIX, emptyContent, metadata);

		// send request to S3 to create folder
		client.putObject(putObjectRequest);
	}

	/**
	 * This method first deletes all the files in given folder and than the
	 * folder itself
	 */
	public static void deleteFolder(String bucketName, String folderName, AmazonS3 client) {
		List fileList = 
				client.listObjects(bucketName, folderName).getObjectSummaries();
		for (S3ObjectSummary file : fileList) {
			client.deleteObject(bucketName, file.getKey());
		}
		client.deleteObject(bucketName, folderName);
	}
}

```