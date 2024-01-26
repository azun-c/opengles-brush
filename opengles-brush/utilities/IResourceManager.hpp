//
//  IResourceManager.h
//  opengles-brush
//
//  Created by azun on 25/01/2024.
//

#pragma once

#include <iostream>
#include <string>
#include "Vector.hpp"

class IResourceManager {
public:
    virtual std::string GetResourcePath() const = 0;
    virtual void LoadPngImage(const std::string& filename) = 0;
    virtual void *GetImageData() = 0;
    virtual ivec2 GetImageSize() = 0;
    virtual void UnloadImage() = 0;
    virtual ~IResourceManager() {}
};

// ファクトリメソッド
IResourceManager *CreateResourceManager();
