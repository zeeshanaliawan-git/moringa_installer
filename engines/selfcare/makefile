
BASEDIR=$(dirname "$0")
echo "$BASEDIR"

cd "$BASEDIR"

dependsFile="depends"
mainClass="com.etn.eshop.Scheduler"

javac -cp ".:lib/*:lib/custom/*" $(find . -name '*.java')

# generate depends file
echo "Main-Class: $mainClass" > $dependsFile

classPath="."
echo 
for filename in lib/*.jar; do
	classPath="$classPath $filename"
done
echo "check for lib/custom folder"
if [ -d lib/custom ]; then
	if [ "$(ls -A lib/custom)" ]; then
		echo "Custom lib folder has files"
		for filename in lib/custom/*.jar; do
			echo "$filename"
			classPath="$classPath $filename"
		done
	fi
fi
echo "Class-Path: $classPath" >> $dependsFile

#build jar file
jar cvmf $dependsFile asimina_selfcare.jar `find com/etn -name \*.class` com/etn/eshop/Scheduler.conf
