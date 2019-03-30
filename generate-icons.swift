import Cocoa

guard CommandLine.arguments.count == 3 else { 

	print("Usage: swift \(CommandLine.arguments[0]) <path/to/largeIcon.png> <path/to/Assets.xcassets/AppIcon.appiconset>")
	exit(1)
}

let inputImagePath = CommandLine.arguments[1]
let inputIconSetPath = CommandLine.arguments[2]
let iconSetJSONURL = URL(fileURLWithPath: inputIconSetPath + "/Contents.json")

let imageTemplate = NSImage(byReferencingFile: inputImagePath)!

let iconSetData = try! Data(contentsOf: iconSetJSONURL)
var iconSet = (try! JSONSerialization.jsonObject(with: iconSetData, options: .mutableContainers)) as! [String: Any]

func resize(image: NSImage, w: Float, h: Float) -> Data {
    let destSize = NSMakeSize(CGFloat(w), CGFloat(h))
    let newImage = NSImage(size: destSize)
    newImage.lockFocus()
    image.draw(
		in: NSMakeRect(0, 0, destSize.width, destSize.height), 
		from: NSMakeRect(0, 0, image.size.width, image.size.height), 
		operation: .sourceOver, 
		fraction: 1
	)
    newImage.unlockFocus()
    newImage.size = destSize
	print(destSize)
    return NSBitmapImageRep(data: newImage.tiffRepresentation!)!.representation(using: .png, properties: [:])!
}

var images = (iconSet["images"] as! [[String: String]]) 
images.enumerated().forEach { data in
	
	let scaleString = data.1["scale"]!
	let nameString = data.1["idiom"]!
	let sizeString = data.1["size"]!

	let scale = Float(scaleString.replacingOccurrences(of: "x", with: ""))!
	let size = Float(sizeString.components(separatedBy: "x").first!)!

	// The Retina display affects scaling. Account for this.
	let screenFactor = Float(NSScreen.main!.backingScaleFactor)
	let side =  size * scale / screenFactor

	print("Scaling \(scale)*\(size) = \(size * scale)")

	let resizedImage = resize(image: imageTemplate, w: side, h: side)
	
	let filename = "\(nameString)_\(sizeString)@\(scaleString).png"
	let path = URL(fileURLWithPath: inputIconSetPath + "/" + filename)
	try! resizedImage.write(to: path)
	images[data.0]["filename"] = filename
}

iconSet["images"] = images

let newIconSetData = try! JSONSerialization.data(withJSONObject: iconSet, options: .prettyPrinted)
try! newIconSetData.write(to: iconSetJSONURL)

print("Done")

