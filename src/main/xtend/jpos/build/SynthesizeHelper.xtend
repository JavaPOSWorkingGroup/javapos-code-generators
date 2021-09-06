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
	
	/**
	 * @return the JavaPOS minor version number passed, but not if the particular category was added later; in that case the minor version when the category
	 * was added is returned 
	 * @param category the category the minor version number is to be checked against
	 * @param minorVersionNumber the requested minimum minor version 
	 */
	def static restrictedMiniumMinorVersionNumber(UposCategory category, int minorVersionNumber) {
    	val minimumMinorVersion = category.minorVersionAdded 
    		 
    	if  (minorVersionNumber < minimumMinorVersion) 
    		return minimumMinorVersion
    	else
    		return minorVersionNumber 
    }
    
    /**
     * @return the major and minor JavaPOS version representation when the given category, property or method had been added to UPOS as
     * a 2 or digit value; so if the version 1.2 "12" is returned, for version 1.13 "113" is returned  
     */
    def static versionWhenAddedToUPOS(UposEntity entity) {
    	val version = entity.minorVersionAdded
    	if (version == 0)
    		'00'
    	else
    		'''1«version»'''
    }
    
    /**
     * @return returns the given minor version preceded with zero if it on digit otherwise unchanged.
     */
    def static zeroPreceded(int minorVersion) {
        String.format("%02d", minorVersion)
    }
    
    /**
     * @return the Java type name representation for the given UPOS property which may be used in generated code as Java type definition
     */
	def static javaPOSType(UposProperty property) {
    	javaPOSType(property.type)
    }
    
    /**
     * @returns the Java type name representation for the given Java type object which may be used in generated code as Java type definition 
     */
    def static javaPOSType(Class<?> type) {
    	if (type.array && type != typeof(String[]) && type != typeof(Object[]))
    		type.canonicalName
    	else
    		type.simpleName
    }
    
    /**
     * @return true if the given UPOS method has an array in its parameters, false otherwise
     */
	def static hasArrayParameterTypes(UposMethod method) {
        
        for (parameterType : method.parameterTypes) {
            if (isUposArrayType(parameterType))
                return true
        }
        return false
    }

	/**
	 * @return true if the given Java type is an array in the sense of the Java language specification 
	 */
    def static isUposArrayType(Class<?> type) {
        switch (type) {
            case typeof(String[]):  return true  
            case typeof(boolean[]): return true
            case typeof(byte[]):    return true
            case typeof(int[]):     return true
            case typeof(long[]):    return true
            case typeof(byte[][]):  return true
            case typeof(int[][]):  return true
            case typeof(Object[]):  return true
        }
        return false
    }
    
    /**
     * @return an Java identifier compliant name for the given type, intended to be used as part of a method name. 
     */
    def static javaPOSTypeAsIdentifierPart(Class<?> type) {
        switch (type) {
            case typeof(String[]):  return 'StringArray'  
            case typeof(boolean[]): return 'BooleanArray'
            case typeof(byte[]):    return 'ByteArray'
            case typeof(int[]):     return 'IntArray'
            case typeof(long[]):    return 'LongArray'
            case typeof(Object[]):  return 'ObjectArray'
            case typeof(byte[][]):  return 'ByteArrayArray'
            case typeof(int[][]):     return 'IntArrayArray'
            default:
                return type.simpleName
        }
    }

    /**
     * Synthesizes a comma separated list of parameter declarations with generic or specific (depends on Eclispe project configuration) 
     * parameter variable names.
     * E.g. "int 'param-name1', long 'param-name1', boolean 'param-name3'"
     */
    def static parameterList(UposMethod method) {
    	method.javaMethod.parameters.map['''«type.javaPOSType» «name»'''].join(', ')
    }
    
    /**
     * Synthesizes a comma separated parameter variable list from the given parameter type array. 
     * E.g. "'param-name1', 'param-name1', 'param-name3'".
     */
    def static argumentList(UposMethod method) {
        method.javaMethod.parameters.map[name].join(', ')
    }

    def static humanReadableName(UposCategory category) {
    	switch (category.name) {
            case "BumpBar": return "Bump Bar" 
            case "CashChanger": return "Cash Changer"
            case "CashDrawer": return "Cash Drawer"
            case "CAT": return "CAT"
            case "CheckScanner": return "Check Scanner" 
            case "FiscalPrinter": return "Fiscal Printer" 
            case "HardTotals": return "Hard Totals"
            case "Keylock": return "Keylock"
            case "LineDisplay": return "Line Display" 
            case "MICR": return "MICR"
            case "MotionSensor": return "Motion Sensor"
            case "MSR": return "MSR"
            case "PINPad": return "PIN Pad" 
            case "PointCardRW": return "PointCard Read Writer" 
            case "POSKeyboard": return "POS Keyboard"
            case "POSPower": return "POS Power"
            case "POSPrinter": return "POS Printer" 
            case "RemoteOrderDisplay": return "Remote Order Display" 
            case "Scale": return "Scale"
            case "Scanner": return "Scanner" 
            case "SignatureCapture": return "Signature Capture" 
            case "ToneIndicator": return "Tone Indicator"
            case "Belt": return "Belt"
            case "BillAcceptor": return "Bill Acceptor" 
            case "BillDispenser": return "Bill Dispenser" 
            case "CoinAcceptor": return "Coin Acceptor"
            case "CoinDispenser": return "Coin Dispenser"
            case "Biometrics": return "Biometrics"
            case "ElectronicJournal": return "Electronic Journal" 
            case "ElectronicValueRW": return "Electronic Value Reader Writer"
            case "Gate": return "Gate"
            case "ImageScanner": return "Image Scanner"  
            case "ItemDispenser": return "Item Dispenser" 
            case "Lights": return "Lights"
            case "RFIDScanner": return "RFID Scanner" 
            case "SmartCardRW": return "Smart Card Reader Writer"
    		default: "UnkownCatgeory"
    	}
    }

	def static CPL_LICENSE_HEADER() '''
       ////////////////////////////////////////////////////////////////////////////////
       //
       // The JavaPOS library source code is under the CPL license, which 
       // is an OSS Apache-like license. The complete license is located at:
       //    http://www.ibm.com/developerworks/library/os-cpl.html
       //
       //------------------------------------------------------------------------------
       // This software is provided "AS IS".  The JavaPOS working group (including
       // each of the Corporate members, contributors and individuals)  MAKES NO
       // REPRESENTATIONS OR WARRANTIES ABOUT THE SUITABILITY OF THE SOFTWARE,
       // EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED
       // WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
       // NON-INFRINGEMENT. The JavaPOS working group shall not be liable for
       // any damages suffered as a result of using, modifying or distributing this
       // software or its derivatives.Permission to use, copy, modify, and distribute
       // the software and its documentation for any purpose is hereby granted.
       ////////////////////////////////////////////////////////////////////////////////
	'''
}
