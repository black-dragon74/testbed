// Command testbed is a throwaway binary used to exercise the
// red-hat-storage/actions go-patch-version action end to end.
package main

import (
	"fmt"

	"github.com/google/uuid"
)

func main() {
	fmt.Printf("testbed run %s\n", uuid.NewString())
}
