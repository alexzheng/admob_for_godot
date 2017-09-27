def can_build(plat):
	return plat=="android" or plat == "iphone"

def configure(env):
	if (env['platform'] == 'android'):
		env.android_add_dependency("compile 'com.google.android.gms:play-services-ads:+'")
		env.android_add_java_dir("android")
		env.android_add_to_manifest("android/AndroidManifestChunk.xml")
		env.disable_module()

	elif env['platform'] == "iphone":
		env.Append(FRAMEWORKPATH=['modules/admob/ios/lib'])
		env.Append(LINKFLAGS=['-ObjC', '-framework','AdSupport', '-framework','AudioToolbox', '-framework','AVFoundation', '-framework','CoreGraphics', '-framework','CoreMedia', '-framework','CoreTelephony', '-framework','EventKit', '-framework','EventKitUI', '-framework','MediaPlayer', '-framework','MessageUI', '-framework','StoreKit', '-framework','SystemConfiguration', '-framework','SafariServices', '-framework','CoreBluetooth', '-framework','CoreMotion', '-framework','AssetsLibrary', '-framework','CoreData', '-framework','CoreLocation', '-framework','CoreText', '-framework','ImageIO', '-framework','OpenGLES', '-framework', 'GLKit', '-framework','CoreVideo', '-framework', 'MobileCoreServices', '-framework', 'GoogleMobileAds','-framework','CFNetwork'])

