package main

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

// isDefinitionFile checks if the basename of the file is definition.yaml or collection.yaml
func isDefinitionFile(file string) bool {
	basename := filepath.Base(file)
	return basename == "definition.yaml" || basename == "collection.yaml"
}

// reduceRelated keeps only the definition files that are siblings or in a parten directory of the given file
func reduceRelated(file string, files []string) []string {
	var relatedFiles []string
	dir := filepath.Dir(file)
	for _, f := range files {
		otherDir := filepath.Dir(f)
		if isDefinitionFile(f) && (strings.Contains(dir, otherDir) || strings.Contains(otherDir, dir)) {
			relatedFiles = append(relatedFiles, f)
		}
	}
	return relatedFiles
}

func main() {
	var missingVersionBump bool

	files := os.Args[1:]
	for _, file := range files {
		// fmt.Println("Processing file ", file)
		if isDefinitionFile(file) {
			// fmt.Println("Skipping definition file ", file)
			continue
		}

		relatedFiles := reduceRelated(file, files)
		if len(relatedFiles) == 0 {
			missingVersionBump = true
			fmt.Println("Error: Version bump missing for file ", file)
		}
	}

	if missingVersionBump {
		os.Exit(1)
	}
}
