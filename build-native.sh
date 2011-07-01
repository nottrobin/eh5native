
# Config
# --
# Filenames
base="eh5-base-native";
complete="eh5-complete-native";
baseLocal="eh5-base-native-local";
completeLocal="eh5-complete-native-local";
# Modules location
modulesPath="../yui3-gallery/build/";

echo "";
echo "Starting process of creating native JS files.";
echo "---";

# Checks
if [ ! -d js/backups ]; then
  echo "Creating 'backup' directory";
  mkdir -p js/backups;
fi;

if [ ! -e ../yui3-gallery ]; then
  echo "You don't appear to have YUI3 gallery checked out.";
  echo "Please ensure that it's checked out at ../yui3-gallery/ relative to this script.";
  exit;
fi;

if [ ! -e ../yui3 ]; then
  echo "You don't appear to have YUI3 checked out.";
  echo "Please ensure that it's checked out at ../yui3/ relative to this script.";
  exit;
fi;

if [ ! -e $modulesPath/gallery-emulatehtml5/gallery-emulatehtml5.js ]; then
  echo "Your yui3-gallery doesn't appear to have 'gallery-emaulatehtml5.";
  echo "Maybe you need to 'up' it?";
  exit;
fi;

# Array of all EH5 modules
jsFileNames=( $base $complete $baseLocal $completeLocal );
cd $modulesPath;
i=0;
for mod in `ls -d gallery-emulatehtml5-*`; do
  if [ -e $mod/js/$mod.js ]; then eh5Modules=( ${eh5Modules[@]} $mod ); fi;
done;
cd -;

echo "EmulateHTML5 modules found:" ${eh5Modules[@]};

# Move all the files we're about to create
for fileName in ${jsFileNames[@]}; do
  echo "Processing "$fileName":";
  # Backup the old version
  if [ -e js/$fileName.js ]; then
    echo -n "Backing up old file: js/"$fileName" to: js/backup"$fileName.`date +%Y-%m-%d.%H%M`.js" ... ";
    mv js/$fileName.js js/backup/$fileName.`date +%Y-%m-%d.%H%M`.js
  fi;
  # Remove the old minified version
  if [ -e js/$fileName-min.js ]; then
    echo -n "Removing old file: js/"$fileName"-min ... ";
    rm js/$fileName-min.js;
  fi;
  
  echo -n "Setting up new js/"$fileName.js" ... ";
  
  # Create the new version
  echo "Creating file ... ";
  touch js/$fileName.js;
  
  # All files start with basic YUI
  echo -n "Adding YUI ... ";
  cat ../yui3/build/yui/yui.js >> js/$fileName.js;
  
  # Now open closure for our code
  echo -n "Opening closure ... ";
  echo "/* Open closure for our modules code */" >> js/$fileName.js;
  echo "( function (Y) {" >> js/$fileName.js;
  
  # Now add EH5 base
  echo -n "Adding base EH5 module ... ";
  cat $modulesPath/gallery-emulatehtml5/gallery-emulatehtml5.js >> js/$fileName.js;
  echo "window.EH5 = Y.EmulateHTML5;" >> js/$fileName.js;
  
  # Now for the "complete" ones add all other EH5 modules
  if [ $fileName == $complete -o $fileName == $completeLocal ]; then
    echo -n "Adding other EH5 modules ... ";
    for moduleName in ${eh5Modules[@]}; do
      echo -n $moduleName" ";
      cat $modulesPath/$moduleName/$moduleName.js >> js/$fileName.js;
    done;
  fi;
  
  # Close closure, passing in YUI object
  echo -n "Starting end of closure ... ";
  echo "/* Close YUI closure */" >> js/$fileName.js;
  echo "} (YUI({" >> js/$fileName.js;
  
  # For local files, setup the local gallery
  echo -n "Adding YUI config options ... ";
  if [ $fileName == $baseLocal -o $fileName == $completeLocal ]; then
    echo "groups: {" >> js/$fileName.js;
    echo "  gallery: {" >> js/$fileName.js;
    echo "    base    : '../../../yui3-gallery/build/'," >> js/$fileName.js;
    echo "    modules: {" >> js/$fileName.js;
    for moduleName in ${eh5Modules[@]}; do
      echo "'"$moduleName"': {}," >> js/$fileName.js;
    done;
    echo "    }" >> js/$fileName.js;
    echo "  }" >> js/$fileName.js;
    echo "}" >> js/$fileName.js;
  fi;
  
  # Finish closing YUI object
  echo -n "Finalising closure ... ";
  echo "})));" >> js/$fileName.js;
  
  # Now compress everything
  echo "Compressing js/"$fileName.js" to js/"$fileName-min.js;
  yuicompressor.jar --nomunge js/$fileName.js -o js/$fileName-min.js;
  
  echo "Finished js/"$fileName.js;
  echo "=====";
  echo "";
done;
