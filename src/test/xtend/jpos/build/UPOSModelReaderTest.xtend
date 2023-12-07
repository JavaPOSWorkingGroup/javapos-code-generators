package jpos.build

import org.junit.Test
import jpos.CashDrawerControl114
import static org.hamcrest.Matchers.*
import static org.hamcrest.MatcherAssert.assertThat
import jpos.ScaleControl114
import org.junit.Ignore
import jpos.FiscalPrinterControl114
import jpos.ElectronicValueRWControl114
import jpos.GestureControlControl116

class UPOSModelReaderTest {

	@Test
	def void testCategoryModelReading() {
	    val modelReader = new UPOSModelReader => [
	        configuration = new UPOSModelReaderConfiguration => [
	            supportedCategories = #
	            [
	                CashDrawerControl114
                ]
			]
		]
		
		val uposModel = modelReader.readUposModelFor('JavaPOSDeviceControls')
	
		
		assertThat(uposModel.categories.length, is(1))
		val cashDrawerCategory = uposModel.categories.head
		assertThat(cashDrawerCategory.name, is("CashDrawer"))
		assertThat(cashDrawerCategory.minorVersionAdded, is(2)) // means, added in 1.2
		
		assertThat(cashDrawerCategory.methods.isNullOrEmpty, is(false))
		assertThat(cashDrawerCategory.methods.map[name].contains("openDrawer"), is(true))
		
		assertThat(cashDrawerCategory.properties.isNullOrEmpty, is(false))
		assertThat(cashDrawerCategory.properties.map[name].contains("State"), is(true)) // a common property
		assertThat(cashDrawerCategory.properties.map[name].contains("DrawerOpened"), is(true)) // a category specific property

		assertThat(cashDrawerCategory.events.isNullOrEmpty, is(false))
		assertThat(cashDrawerCategory.events.map[name].contains("StatusUpdate"), is(true))
		assertThat(cashDrawerCategory.events.size, is(2))		
	}
	
	@Test
	def void testMethodModelReading() {
	    val modelReader = new UPOSModelReader => [
	        configuration = new UPOSModelReaderConfiguration => [
	            supportedCategories = #
	            [
	                CashDrawerControl114
                ]
			]
		]
		
		val uposModel = modelReader.readUposModelFor('JavaPOSDeviceControls')
	
		assertThat(uposModel.categories.length, is(1))
		val cashDrawerCategory = uposModel.categories.head

		assertThat(cashDrawerCategory.methods.isNullOrEmpty, is(false))
		assertThat(cashDrawerCategory.methods.filter[name == "waitForDrawerClose"].size, is(1))
		
		val waitForDrawerCloseMethod = cashDrawerCategory.methods.filter[name == "waitForDrawerClose"].head
		
		assertThat(waitForDrawerCloseMethod.name, is("waitForDrawerClose"))
		assertThat(waitForDrawerCloseMethod.minorVersionAdded, is(2)) // added in 1.2
		assertThat(waitForDrawerCloseMethod.categoryBelongingTo, is(cashDrawerCategory))

		assertThat(waitForDrawerCloseMethod.parameterTypes.isNullOrEmpty, is(false))
		assertThat(waitForDrawerCloseMethod.parameterTypes, is(#[int,int,int,int] as Class<?>[]))
	}

	@Ignore("This runs well in Eclipse environments only, because needs some special compilation configuration")
	@Test
	def void testParameterNaming() {
	    val modelReader = new UPOSModelReader => [
	        configuration = new UPOSModelReaderConfiguration => [
	            supportedCategories = #
	            [
	                CashDrawerControl114
                ]
			]
		]
		
		val uposModel = modelReader.readUposModelFor('JavaPOSDeviceControls')
	
		assertThat(uposModel.categories.length, is(1))
		val cashDrawerCategory = uposModel.categories.head

		assertThat(cashDrawerCategory.methods.isNullOrEmpty, is(false))
		assertThat(cashDrawerCategory.methods.filter[name == "waitForDrawerClose"].size, is(1))
		
		val waitForDrawerCloseMethod = cashDrawerCategory.methods.filter[name == "waitForDrawerClose"].head
		
		// here is an example how parameter names as in the source code may be applied to generated code
		// this however requires the javapos-contracts project being configured correctly (apropos 
		// org.eclipse.jdt.core.compiler.codegen.methodParameters=generate), running in Eclipse 
		assertThat(waitForDrawerCloseMethod.javaMethod.parameters.map[name], 
			is(#['beepTimeout', 'beepFrequency','beepDuration', 'beepDelay']))
	}

	@Test
	def void testPropertyModelReading() {
	    val modelReader = new UPOSModelReader => [
	        configuration = new UPOSModelReaderConfiguration => [
	            supportedCategories = #
	            [
	                CashDrawerControl114
                ]
			]
		]
		
		val uposModel = modelReader.readUposModelFor('JavaPOSDeviceControls')
	
		assertThat(uposModel.categories.length, is(1))
		val cashDrawerCategory = uposModel.categories.head

		assertThat(cashDrawerCategory.properties.isNullOrEmpty, is(false))
		assertThat(cashDrawerCategory.properties.filter[name == "DrawerOpened"].size, is(1))
		
		val drawerOpenedProperty = cashDrawerCategory.properties.filter[name == "DrawerOpened"].head
		
		assertThat(drawerOpenedProperty.name, is("DrawerOpened"))
		assertThat(drawerOpenedProperty.minorVersionAdded, is(2)) // added in 1.2
		assertThat(drawerOpenedProperty.categoryBelongingTo, is(cashDrawerCategory))
		assertThat(drawerOpenedProperty.readonly, is(true))

		assertThat(drawerOpenedProperty.type.simpleName, is("boolean"))
	}

	@Test
	def void testVersionAdded() {
	    val modelReader = new UPOSModelReader => [
	        configuration = new UPOSModelReaderConfiguration => [
	            supportedCategories = #
	            [
	                ScaleControl114
                ]
			]
		]
		
		val uposModel = modelReader.readUposModelFor('JavaPOSDeviceControls')
	
		assertThat(uposModel.categories.length, is(1))
		val scaleCategory = uposModel.categories.head

		assertThat(scaleCategory.properties.isNullOrEmpty, is(false))
		assertThat(scaleCategory.properties.filter[name == "ZeroValid"].size, is(1))
		
		val zeroValidProperty = scaleCategory.properties.filter[name == "ZeroValid"].head
		
		assertThat(zeroValidProperty.minorVersionAdded, is(13)) // added in 1.13
		assertThat(zeroValidProperty.readonly, is(false)) // it has a setter
	}
	
	@Test
	def void testSpecialFiscalMethodsWithSetPrefix() {
        val modelReader = new UPOSModelReader => [
            configuration = new UPOSModelReaderConfiguration => [
                supportedCategories = #
                [
                    FiscalPrinterControl114
                ]
            ]
        ]
        
        val uposModel = modelReader.readUposModelFor('JavaPOSDeviceControls')
    
        assertThat(uposModel.categories.length, is(1))
        val fiscalPrinterCategory = uposModel.categories.head

        assertThat(fiscalPrinterCategory.properties.contains('StoreFiscalID'), is(false))
        assertThat(fiscalPrinterCategory.properties.contains('Date'), is(false))
        assertThat(fiscalPrinterCategory.properties.contains('Currency'), is(false))
        
        assertThat(fiscalPrinterCategory.methods.filter[name == 'setStoreFiscalID'].size, is(1))
        assertThat(fiscalPrinterCategory.methods.filter[name == 'setDate'].size, is(1))
        assertThat(fiscalPrinterCategory.methods.filter[name == 'setCurrency'].size, is(1))
	}
	
	@Test
    def void testSpecialScaleMethodsWithSetPrefix() {
        val modelReader = new UPOSModelReader => [
            configuration = new UPOSModelReaderConfiguration => [
                supportedCategories = #
                [
                    ScaleControl114
                ]
            ]
        ]
        
        val uposModel = modelReader.readUposModelFor('JavaPOSDeviceControls')
    
        assertThat(uposModel.categories.length, is(1))
        val scaleCategory = uposModel.categories.head
        
        assertThat(scaleCategory.properties.contains('PriceCalculationMode'), is(false))
        assertThat(scaleCategory.properties.contains('TarePrioity'), is(false))
        assertThat(scaleCategory.properties.contains('TarePriority'), is(false))
        
        assertThat(scaleCategory.methods.filter[name == 'setPriceCalculationMode'].size, is(1))
        assertThat(scaleCategory.methods.filter[name == 'setTarePrioity'].size, is(1))
        assertThat(scaleCategory.methods.filter[name == 'setTarePriority'].size, is(1))
    }
	
	@Test
    def void testSpecialGestureMethodsWithSetPrefix() {
        val modelReader = new UPOSModelReader => [
            configuration = new UPOSModelReaderConfiguration => [
                supportedCategories = #
                [
                    GestureControlControl116
                ]
            ]
        ]
        
        val uposModel = modelReader.readUposModelFor('JavaPOSDeviceControls')
    
        assertThat(uposModel.categories.length, is(1))
        val gestureCategory = uposModel.categories.head
        
        assertThat(gestureCategory.properties.contains('Position'), is(false))
        assertThat(gestureCategory.properties.contains('Speed'), is(false))
        
        assertThat(gestureCategory.methods.filter[name == 'setPosition'].size, is(1))
        assertThat(gestureCategory.methods.filter[name == 'getPosition'].size, is(1))
        assertThat(gestureCategory.methods.filter[name == 'setSpeed'].size, is(1))
    }
	
    @Test
    def void testWronglyNamedPropertyWithoutGetPrefix() {
        val modelReader = new UPOSModelReader => [
            configuration = new UPOSModelReaderConfiguration => [
                supportedCategories = #
                [
                    ElectronicValueRWControl114
                ]
            ]
        ]
        
        val uposModel = modelReader.readUposModelFor('JavaPOSDeviceControls')
    
        assertThat(uposModel.categories.length, is(1))
        val electronicRWCategory = uposModel.categories.head
        
        assertThat(electronicRWCategory.properties.contains('CapTrainingMode'), is(false))

        assertThat(electronicRWCategory.methods.filter[name == 'CapTrainingMode'].size, is(0))
    }
    
}