//
// Run this from the Run menu or press F5
//


uses javax.xml.parsers.DocumentBuilder;
uses javax.xml.parsers.DocumentBuilderFactory;
uses javax.xml.soap.MessageFactory;
uses javax.xml.soap.MimeHeaders;
uses javax.xml.soap.SOAPMessage;
uses javax.xml.transform.dom.DOMSource;
uses org.xml.sax.InputSource;
uses javax.xml.transform.Transformer;
uses javax.xml.transform.TransformerFactory;
uses javax.xml.transform.stream.StreamResult;

uses java.nio.charset.Charset;
uses java.nio.file.Files;
uses java.nio.file.Paths;

uses org.w3c.dom.Document;
uses org.w3c.dom.NodeList

uses java.io.File
uses java.io.StringWriter;
uses java.io.StringReader;
uses java.io.ByteArrayOutputStream;
uses java.io.ByteArrayInputStream;
uses java.util.ArrayList;
uses java.util.List;
uses java.util.HashMap

print("Hello, Test with files")

var fichero : File = new File("D:\\ESTUDIO\\REPASO\\JAVA\\Gestficheros\\GestXML\\response.xml") //Modificar
print("fichero recogido")
print("La ruta del fichero es: "+fichero.AbsolutePath)

var request = fileToString(fichero)
print("Request as String: ")
print(request)

var soapRequest =  getSoapMessageFromXmlString(request)
print("Request as Message:")
soapRequest.writeTo(System.out)

print("Comentario de la nueva rama")
print("value of tag Targa:")
print(getValueFromSoapMessageAttribute(soapRequest, "ns4:item"))

var col = getLengthFromSoapMessageAttribute(soapRequest, "ns3:attestati")
var iter = 0
while(iter< col){
var maped = getMapFromNode(getDocumentFromSoapMessage(soapRequest).getElementsByTagName("ns3:attestati").item(iter).ChildNodes) 
maped.eachKeyAndValue( \ key, value -> print("key : " + key + ", value : " + value ) )
iter +=1
}

var list = getColectionFromSoapMessageAttribute(soapRequest, "ns4:item")



print("Change value Targa:")
soapRequest = setValueFromSoapMessageAttribute(soapRequest,"Targa", "FF678JU" )
print(getValueFromSoapMessageAttribute(soapRequest, "Targa"))



private function getMapFromNode (nodelist : NodeList) : HashMap{
 var map = new HashMap()
 var i = 0
while (i<nodelist.Length){
  map.put(nodelist.item(i).NodeName, nodelist.item(i).TextContent ) 
  i += 1
}
 
 
 return map
}  

/**
 * Create String from File
 */
private function fileToString(f : File) : String {
  var s : String = ""
  
  try{
  var ls = Files.readAllLines(Paths.get(f.getAbsolutePath()))
  var asString : String = ""
  
  for (st in ls){
    s += st.trim()
  }
}catch(e : Exception){
  e.printStackTrace()
}
  
  return s
}


/**
 * Create Message from String
 */
private function getSoapMessageFromXmlString(xml : String) : SOAPMessage {
  var soapm : SOAPMessage
  var factory : MessageFactory = MessageFactory.newInstance()
  
  try{
      soapm = factory.createMessage(new MimeHeaders(), new ByteArrayInputStream(xml.getBytes(Charset.forName("UTF-8"))))
  }catch(e : Exception){
     e.printStackTrace() 
  } 
  
  return soapm
}

/**
 * Create String form SoapMessage
 */
private function getStringFromSoapMessage (soap : SOAPMessage ) : String{
  var str = ""
 
  try {
  var baos = new ByteArrayOutputStream()
  soap.writeTo(baos)
  str = new String(baos.toByteArray())    
  }catch(e : Exception){    
  }  
  return str
}


/**
 * Get value from SOAPMesssage
 */
private function getValueFromSoapMessageAttribute (soapm : SOAPMessage, label  : String) : String {   
  return getDocumentFromSoapMessage(soapm).getElementsByTagName(label).item(0).getTextContent()
}


private function getColectionFromSoapMessageAttribute(soapm : SOAPMessage, label  : String) : NodeList {
return getDocumentFromSoapMessage(soapm).getElementsByTagName(label).item(0).ChildNodes  
}
private function getLengthFromSoapMessageAttribute(soapm : SOAPMessage, label  : String) : int {
return getDocumentFromSoapMessage(soapm).getElementsByTagName(label).Length
}

/**
 * Set ValueFromSoapMessage
 */
private function setValueFromSoapMessageAttribute (soapm : SOAPMessage, label  : String, value : String) : SOAPMessage {
 var doctrans = getDocumentFromSoapMessage(soapm)
 doctrans.getElementsByTagName(label).item(0).setTextContent(value)
 
 var trans = TransformerFactory.newInstance().newTransformer()
 var writer = new StringWriter ()
 trans.transform(new DOMSource(doctrans), new StreamResult(writer))
 
 soapm = getSoapMessageFromXmlString(writer.getBuffer().toString())
 
 return soapm 
}

private function getDocumentFromSoapMessage (soapmss : SOAPMessage) : Document {
  var doc :  Document
  
  var xml = getStringFromSoapMessage(soapmss)  
  var builder = DocumentBuilderFactory.newInstance().newDocumentBuilder()
  doc = builder.parse(new InputSource(new StringReader(xml)))
    
  doc.getDocumentElement().normalize()
  
  return doc
}


