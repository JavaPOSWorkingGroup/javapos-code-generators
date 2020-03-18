package jpos.build

import java.lang.reflect.Method
import java.util.ArrayList
import java.util.HashSet
import java.util.List
import java.util.Set
import java.util.regex.Pattern
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.Data
import jpos.BaseControl

@Accessors class UPOSModelReaderConfiguration {
    List<Class<? extends BaseControl>> supportedCategories = new ArrayList
    Set<String> omittedReadProperties = new HashSet
    Set<String> omittedWriteProperties = new HashSet
    Set<String> omittedMethods = new HashSet
}

class UPOSModelReader {
    
    @Accessors UPOSModelReaderConfiguration configuration = new UPOSModelReaderConfiguration
    
    def static isSetter(Method method) { method.name.startsWith('set') && method.parameterTypes.length == 1 }

    def static isGetter(Method method) { method.name.startsWith('get') && method.returnType != void }
    
    def static isFiscalPrinterSetMethod(Method method) {
        method.declaringClass.simpleName.contains('FiscalPrinter') 
        && (method.name == 'setDate' || method.name == 'setCurrency' || method.name == 'setStoreFiscalID') 
    }

    def static isScaleSetMethod(Method method) { // added in UnifiedPOS 1.14
        method.declaringClass.simpleName.contains('Scale') 
        && (method.name == 'setPriceCalculationMode' || method.name == 'setTarePrioity') 
    }
    
    def static isWronglyNamedGetProperty(Method method) { // added in UnifiedPOS 1.14
        method.declaringClass.simpleName.contains('ElectronicValueRW') && method.name == 'CapTrainingMode' // lacking "get" prefix
    }
    
    val static correctedWronglyNamedPropertyName = #{
        'CapTrainingMode' -> 'CapTrainingMode' 
    }
    
    // higher order function objects
    val readWriteUposProperty = [Method method | method.declaringClass != Class::forName('java.lang.Object')
        && method.isSetter && !method.isFiscalPrinterSetMethod && !method.isScaleSetMethod
        && !configuration?.omittedWriteProperties?.contains(method.name)
        && !configuration?.omittedWriteProperties?.contains('''«method.declaringClass.simpleName».«method.name»'''.toString())
    ]

    val potentialReadOnlyUposProperty = [Method method | method.declaringClass != Class::forName('java.lang.Object')
        && (method.isGetter || method.isWronglyNamedGetProperty)
        && !configuration?.omittedReadProperties?.contains(method.name) 
        && !configuration?.omittedReadProperties?.contains('''«method.declaringClass.simpleName».«method.name»'''.toString()) 
    ]

    val uposMethod = [Method method | method.declaringClass != Class::forName('java.lang.Object')
        && (!(method.isGetter || method.isSetter) || method.isFiscalPrinterSetMethod || method.isScaleSetMethod)
        && !method.isWronglyNamedGetProperty 
        && !method.name.endsWith('Listener')
        && !configuration?.omittedMethods?.contains(method.name)
        && !configuration?.omittedMethods?.contains('''«method.declaringClass.simpleName».«method.name»'''.toString()) 
    ]

    val uposEvent = [Method method | method.declaringClass != Class::forName('java.lang.Object')
        && method.name.startsWith('add')
        && method.name.endsWith('Listener')
    ]
    
    def UposModel readUposModelFor(String modelName) {
        new UposModel(modelName) => [
            configuration?.supportedCategories?.forEach
            [ 
                category | it.categories.add(new UposCategory(category.programmaticName, category.versionFirstDefinedIn, category) => [        
                    category.methods
                        .filter(uposMethod)
                        .forEach[method|methods.addUposMethod(method, it)]
                    
                    val writePropertyNames = category.methods
                        .filter(readWriteUposProperty)
                        .fold(new ArrayList<Method>())[list, method| list.add(method); list]
                        
                    writePropertyNames.forEach[property|
                    	properties.addUposReadWriteProperty(property, it)
                    ]
                    
                    val Set<String> writeProperties = newHashSet
                    writePropertyNames.forEach[property|
                        writeProperties.add(property.pureUposPropertyName) // add property name w/o the set prefix
                    ]
                    val readOnlyPropertyNames = category.methods
                        .filter(potentialReadOnlyUposProperty)
                        .fold(new ArrayList<Method>) 
                            [ List<Method> list, property | 
                                if (!writeProperties.contains(property.pureUposPropertyName)) 
                                    list.add(property); list 
                            ]
                    readOnlyPropertyNames.forEach[property|properties.addUposReadOnlyProperty(property, it)]
                
                    category.methods
                        .filter(uposEvent)
                        .forEach[m|events.addUposEvent(m, it)]
                
                    // sort all to ensure same order on any generation
                    properties.sortInplaceBy[name]
                    methods.sortInplaceBy[name]
                    events.sortInplaceBy[name]
                ])
            ]
        ]
    }
	
	def programmaticName(Class<? extends BaseControl> controlClass) {
		controlClass.simpleName.replaceFirst('Control1\\d+', '')
	}
    
    /**
     * The UPOS property name without the get or set prefix or the corrected property name if it is listed by correctedWronglyNamedPropertyName 
     */
    def static pureUposPropertyName(Method property) {
        val nameWithoutGetSetPrefix = property.name.substring(3) 
        if (property.isWronglyNamedGetProperty)
            correctedWronglyNamedPropertyName.getOrDefault(property.name, nameWithoutGetSetPrefix)
        else
            nameWithoutGetSetPrefix
    }
    
    def static addUposMethod(List<UposMethod> uposMethods, Method method, UposCategory category) {
        uposMethods.add(new UposMethod(method.name, method.versionFirstDefinedIn, category, method.parameterTypes, method))
    }
    
    def static addUposReadWriteProperty(List<UposProperty> uposProperties, Method property, UposCategory category) {
        uposProperties.add(UposProperty::ReadWrite(property.pureUposPropertyName, property.parameterTypes.get(0), category, property.versionFirstDefinedIn))   
    }
    
    def static addUposReadOnlyProperty(List<UposProperty> uposProperties, Method property, UposCategory category) {
        uposProperties.add(UposProperty::ReadOnly(property.pureUposPropertyName, property.returnType, category, property.versionFirstDefinedIn))
    }
    
    def static addUposEvent(List<UposEvent> uposEvents, Method m, UposCategory category) {
        uposEvents.add(new UposEvent(m.eventName, m.versionFirstDefinedIn, category))   
    }
    
    def static eventName(Method method) {
        if (!(method.name.startsWith('add') && method.name.endsWith('Listener'))) throw new UnsupportedOperationException("unsupported method name " + method.name)  
        return method.name.substring(3).replace('Listener', '')
    }

   	val static controlClassPattern = Pattern.compile("\\w+\\D1(?<version>\\d+)")
    
    def static int versionFirstDefinedIn(Class<?> categoryClass) {
    	val superClass = categoryClass.interfaces.findFirst[controlClassPattern.matcher(simpleName).matches]
    	if (superClass === null)
    		extractUnfiedPOSVersion(categoryClass.simpleName)
    	else
    		UPOSModelReader.versionFirstDefinedIn(superClass)
    }
    
    def static int versionFirstDefinedIn(Method method) {
    	extractUnfiedPOSVersion(method.declaringClass.simpleName)
    }
    
    def private static int extractUnfiedPOSVersion(String categoryClassName) {
    	val controlClassMatcher = controlClassPattern.matcher(categoryClassName)
    	if (controlClassMatcher.matches) {
    		val versionStr = controlClassMatcher.group("version")
    		try {
	    		Integer.parseInt(versionStr) 
    		}
    		catch (NumberFormatException nfe) {
    			return 0; // undefined, should not happen
    		}
    	}
    	else
    		return 0; // undefined, should not happen 
    }

}



@Data class UposModel {
    String name
    ArrayList<UposCategory> categories = newArrayList
}

@Data class UposEntity {
    String name
    int minorVersionAdded
}

@Data class UposFeature extends UposEntity {
    UposCategory categoryBelongingTo
}

@Data class UposCategory extends UposEntity {
    List<UposMethod> methods = newArrayList
    List<UposProperty> properties = newArrayList        
    List<UposEvent> events = newArrayList
    Class<?> javaClass
}

@Data class UposMethod extends UposFeature {
    Class<?>[] parameterTypes
    Method javaMethod
}

@Data class UposProperty extends UposFeature {
    def static ReadOnly(String name, Class<?> returnType, UposCategory categoryBelongigTo, int unifiedPOSversionFirstIn) { 
    	new UposProperty(name, unifiedPOSversionFirstIn, categoryBelongigTo, true, returnType)
    }
    def static ReadWrite(String name, Class<?> returnType, UposCategory categoryBelongigTo, int unifiedPOSversionFirstIn) { 
    	new UposProperty(name, unifiedPOSversionFirstIn, categoryBelongigTo, false, returnType)
    }
    boolean readonly
    Class<?> type
	
}

@Data class UposEvent extends UposFeature {}


