# Create normal native object
cat includes/yui.js includes/open-closure.js ../yui3-gallery/src/gallery-emulatehtml5-loader/js/loader.js includes/instantiate-native.js includes/close-closure.js > js/native.js;
# Compress
yuicompressor.jar js/native.js > js/native-min.js;

# Create local native object - for accessing gallery objects locally
cat includes/yui.js includes/open-closure.js ../yui3-gallery/src/gallery-emulatehtml5-loader/js/loader.js includes/instantiate-native.js includes/close-closure-local.js > js/native-local.js;
# Compress
yuicompressor.jar js/native-local.js > js/native-local-min.js;
