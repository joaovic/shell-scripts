#!/usr/bin/env bash
#javac -Xlint:unchecked -cp ".:./jackson-core-2.10.0.jar:./jackson-databind-2.10.0.jar:./jackson-annotations-2.10.0.jar:./jackson-datatype-jdk8-2.10.0.jar" $1
# javac -cp ".:./jackson-core-2.10.0.jar:./jackson-databind-2.10.0.jar:./jackson-annotations-2.10.0.jar:./jackson-datatype-jdk8-2.10.0.jar" $1
#java  -cp ".:./jackson-core-2.10.0.jar:./jackson-databind-2.10.0.jar:./jackson-annotations-2.10.0.jar:./jackson-datatype-jdk8-2.10.0.jar" ${1%.java}

javac $1
if [ $? -eq 0 ]; then
	java  ${1%.java}
fi