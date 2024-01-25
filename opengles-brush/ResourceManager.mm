//
//  ResourceManager.m
//  opengles-brush
//
//  Created by azun on 25/01/2024.
//

#include "IResourceManager.hpp"

class ResourceManager : public IResourceManager {
public:
    std::string GetResourcePath() const {
        NSString *bundlePath =[[NSBundle mainBundle] resourcePath];
        return [bundlePath UTF8String];
    }
    void LoadPngImage(const std::string& name) {
        UIImage *uiImage = [UIImage imageNamed:[NSString stringWithUTF8String:name.c_str()]];
        CGImageRef cgImage = uiImage.CGImage;
        m_imageSize.x = (int)CGImageGetWidth(cgImage);
        m_imageSize.y = (int)CGImageGetHeight(cgImage);
        m_imageData = CGDataProviderCopyData(CGImageGetDataProvider(cgImage));
    }
    
    void *GetImageData() {
        return (void *) CFDataGetBytePtr(m_imageData);
    }
    
    ivec2 GetImageSize() {
        return m_imageSize;
    }
    
    void UnloadImage() {
        CFRelease(m_imageData);
    }
    
private:
    ivec2 m_imageSize;
    CFDataRef m_imageData;
};

IResourceManager *CreateResourceManager() {
    return new ResourceManager();
}
