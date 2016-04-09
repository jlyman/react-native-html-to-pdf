# react-native-html-to-pdf

Convert html strings to PDF documents using React Native

### Add it to your project

1. Run `npm install react-native-html-to-pdf --save`
2. Open your project in XCode, right click on [Libraries](http://url.brentvatne.ca/jQp8) and select [Add Files to "Your Project Name](http://url.brentvatne.ca/1gqUD).
3. Add `libRNHTMLtoPDF.a` to `Build Phases -> Link Binary With Libraries`
   [(Screenshot)](http://url.brentvatne.ca/17Xfe).

## Usage
```javascript

var React = require('react-native');

var {
  AlertIOS,
  AppRegistry,
  NativeModules: {
    RNHTMLtoPDF,
  }
  StyleSheet,
  Text,
  TouchableHighlight,
  View,
} = React;

var Example = React.createClass({

  createPDF() {
    var options = {
      html: '<h1>PDF TEST</h1>', // HTML String
      
      fileName: 'test',          /* Optional: Custom Filename excluded extention
                                    Default: Randomly generated
                                  */

      directory: 'docs'          /* Optional: 'docs' will save the file in the `Documents`
                                    Default: Temp directory
                                  */

      height: 800                /* Optional: 800 sets the height of the DOCUMENT that will be produced
                                    Default: 612
                                  */
      width: 1056                /* Optional: 1056 sets the width of the DOCUMENT that will produced
                                    Default: 792
                                  */
      padding: 24                 /* Optional: 24 is the # of pixels between the outer paper edge and
                                            corresponding content edge.  Example: width of 1056 - 2*padding
                                            => content width of 1008
                                    Default: 10
                                  */
      ownerPassword: 'pword1'     /* Optional: Sets an owner password on the generated PDF document (restricts
                                            the ability to change document settings like printability, etc.)
                                    Default: unused
                                  */
                                    
      userPassword: 'pword2'      /* Optional: Sets a user password on the generated PDF document that must
                                            be supplied in order to open the document. Also encrypts the PDF.
                                    Default: unused
                                  */
      encryptionKeyLength: 128    /* Optional: If either ownerPassword or userPassword is set, this can also be
                                            set to modify the encryption key length used to encrypt the PDF. By
                                            default iOS will use a 40-bit key, but you can specify any key 
                                            length between 40 and 128 as long as it is a multiple of 8.
                                    Default: unused
                                  */
    };
    
    RNHTMLtoPDF.convert(options).then((filePath) => {
      console.log(filePath);
    });
  },

  render() {
    <View>
      <TouchableHighlight onPress={this.createPDF}>
        <Text>Create PDF</Text>
      </TouchableHighlight>
    </View>
  }
});
```

## Example
The example project included demonstrates how you can create a PDF file from a html string and email it as an attachment using `react-native-mail`.
