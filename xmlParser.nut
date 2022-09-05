class XmlNode {
	constructor(_name, _attributes, _childNodes) {
		this.name = _name;
		this.attributes = _attributes;
		this.childNodes = _childNodes;
	}

	name = "";
	attributes = [];
	childNodes = [];

	function tostring(child = false) {
		local result = child ? "" : "\n\n=================================================\n";
		result += format("[XmlNode] Name: %s\n", name);
		foreach(attribute in this.attributes) {
			result += attribute.tostring() + "\n";
		}
		foreach(childNode in this.childNodes) {
			result += "[XmlNode] Child node:\n";
			result += childNode.tostring(true);
		}
		result += child ? "" : "==================================================\n\n";
		return result;
	}
}

class XmlAttribute {
	constructor(_name, _value) {
		this.name = _name;
		this.value = _value;
	}

	function tostring() {
		return format("[XmlAttribute] Name: %s\n[XmlAttribute] Value: %s", this.name, this.value);
	}
	name = "";
	value = "";
}

class XmlParser {
#public
	constructor() {
	}

	function parse(xmlString) {
		return findNodes(xmlString);
	}
#private
	function findOpenTag(xmlString, startIndex) {
		local openTagIndex = xmlString.find("<", startIndex);
		if(openTagIndex == null) {
			return null;
		}
		local closeTagIndex = xmlString.find(">", openTagIndex);
		if(closeTagIndex == null) {
			return null;
		}
		if(["?", "/"].find(xmlString.slice(openTagIndex + 1, openTagIndex + 2)) != null) {
			return {name = null, startPosition = null, endPosition = closeTagIndex};
		}
		local tagName = xmlString.slice(openTagIndex + 1, closeTagIndex);
		tagName = split(tagName, " ")[0];
		return {name = tagName, startPosition = openTagIndex + 1, endPosition = closeTagIndex};
	}

	function findCloseTag(xmlString, tagName, startIndex) {
		local fullTagName = format("</%s>", tagName);
		local index = xmlString.find(fullTagName, startIndex);
		if(index == null) {
			fullTagName = "/>";
			index = xmlString.find(fullTagName, startIndex - 2);
			if(index == null) {
				throw format("[xmlError] closing tag %s not found. Position: %d", tagName, startIndex);
			}
		}
		return {startPosition = index, endPosition = index + fullTagName.len()};
	}

	function findAttributes(xmlString, startPosition, endPosition) {
		local attributes = split(xmlString.slice(startPosition, endPosition), " ");
		attributes.remove(0);
		local result = [];
		foreach(attribute in attributes) {
			if(attribute == "=") {
				throw format("[xmlError] don't use whitespaces between attributes and it's values! Position: %d", startPosition);
			}
			local attributeValue = split(attribute, "=");
			result.push(XmlAttribute(attributeValue[0], attributeValue[1]));
		}
		return result;
	}

	function findNodes(xmlString, index = 0) {
		local result = [];
		local openTag = null;
		do {
			openTag = findOpenTag(xmlString, index);
			if(openTag == null) {
				break;
			}
			if(openTag.name == null) {
				index = openTag.endPosition;
				continue;
			}
			local attributes = findAttributes(xmlString, openTag.startPosition, openTag.endPosition - 1);
			local closeTag = findCloseTag(xmlString, openTag.name, openTag.endPosition);
			index = closeTag.endPosition;
			result.push(XmlNode(openTag.name, attributes, findNodes(xmlString.slice(openTag.startPosition + 1, closeTag.startPosition))));
		} while(openTag != null);
		return result;
	}
}