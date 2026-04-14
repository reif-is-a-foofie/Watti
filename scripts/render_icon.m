#import <Cocoa/Cocoa.h>

static NSColor *WNColor(CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha) {
    return [NSColor colorWithSRGBRed:red green:green blue:blue alpha:alpha];
}

static BOOL WritePNG(NSImage *image, NSString *path) {
    NSData *tiff = image.TIFFRepresentation;
    if (tiff.length == 0) {
        return NO;
    }
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithData:tiff];
    if (rep == nil) {
        return NO;
    }
    NSData *png = [rep representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
    if (png.length == 0) {
        return NO;
    }
    return [png writeToFile:path atomically:YES];
}

static NSImage *DrawIcon(NSInteger size) {
    NSSize canvas = NSMakeSize(size, size);
    NSImage *image = [[NSImage alloc] initWithSize:canvas];
    [image lockFocus];

    NSRect rect = NSMakeRect(0, 0, size, size);
    CGFloat radius = (CGFloat)size * 0.22;
    NSBezierPath *background = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(rect, 0.5, 0.5)
                                                               xRadius:radius
                                                               yRadius:radius];

    NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:WNColor(0.98, 0.99, 0.99, 1.0)
                                                        endingColor:WNColor(0.94, 0.95, 0.96, 1.0)];
    [gradient drawInBezierPath:background angle:90];

    [WNColor(0.0, 0.0, 0.0, 0.10) setStroke];
    background.lineWidth = MAX(1.0, (CGFloat)size * 0.02);
    [background stroke];

    NSImage *symbol = [NSImage imageWithSystemSymbolName:@"bolt.fill" accessibilityDescription:@"Watti"];
    if (symbol != nil) {
        if (@available(macOS 11.0, *)) {
            CGFloat pointSize = (CGFloat)size * 0.56;
            NSImageSymbolConfiguration *config = [NSImageSymbolConfiguration configurationWithPointSize:pointSize
                                                                                                weight:NSFontWeightSemibold
                                                                                                 scale:NSImageSymbolScaleMedium];
            symbol = [symbol imageWithSymbolConfiguration:config] ?: symbol;
            NSRect boltRect = NSMakeRect((size - pointSize) / 2.0,
                                         (size - pointSize) / 2.0 + (CGFloat)size * 0.02,
                                         pointSize,
                                         pointSize);
            [[NSColor systemGreenColor] set];
            [symbol drawInRect:boltRect
                      fromRect:NSZeroRect
                     operation:NSCompositingOperationSourceAtop
                      fraction:1.0];
        }
    }

    [image unlockFocus];
    return image;
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc != 3) {
            fprintf(stderr, "usage: render_icon <size> <output.png>\n");
            return 2;
        }
        NSInteger size = (NSInteger)strtol(argv[1], NULL, 10);
        NSString *outPath = [NSString stringWithUTF8String:argv[2]];
        if (size <= 0 || outPath.length == 0) {
            fprintf(stderr, "invalid args\n");
            return 2;
        }

        NSImage *image = DrawIcon(size);
        if (!WritePNG(image, outPath)) {
            fprintf(stderr, "failed to write png\n");
            return 1;
        }
    }
    return 0;
}

