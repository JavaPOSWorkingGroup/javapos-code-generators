package jpos.build

import java.io.BufferedWriter
import java.io.File
import java.io.FileWriter
import java.util.ArrayList
import java.util.List
import org.eclipse.xtext.xbase.lib.Functions.Function2

class SynthesizeHelper {

	/**
	 * Creates the given file with the given content in. Write a log message to stdout which file has been written. 
	 * @param outputFile File object the content has to b written to 
	 * @param content the content to written to the file
	 */
	def static void generateFile(File outputFile, CharSequence content) {
        val file = new BufferedWriter(new FileWriter(outputFile))
        println("generate file " + outputFile.name)
        file.write(content.toString());
        file.close
    }
	

	/**
	 * Synthesize a index-based list for a given list of types applying to the given lambda method to each type element in the list 
	 * providing type and index to the passed lambda method. The index is starting with zero.
	 * @param list the list of type to be synthesize
	 * @param synthesizePattern the lambda function to be applied to each element in the given list decorated with the element and it index in the list 
	 */
	def static <T> asIndexList(List<T> list, Function2<T, Integer, CharSequence> synthesizePattern, CharSequence separator) {
		val resultList = new ArrayList<CharSequence>
		list.forEach[T type, Integer index | resultList.add(synthesizePattern.apply(type, index))]
		resultList.filter[length>0].join(separator)
	}
	
	
}