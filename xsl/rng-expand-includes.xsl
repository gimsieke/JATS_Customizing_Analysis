<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:rng="http://relaxng.org/ns/structure/1.0"
  version="3.0" exclude-result-prefixes="xs rng">
  
  <xsl:mode on-no-match="shallow-copy"/>
  
  <xsl:template match="rng:include">
    <xsl:apply-templates select="doc(resolve-uri(@href, base-uri(/)))/rng:grammar/node()"/>
  </xsl:template>
  
  <xsl:template match="rng:define/@name">
    <xsl:next-match/>
    <xsl:attribute name="xml:base" select="tokenize(base-uri(), '/')[last()]"/>
<!--    <xsl:attribute name="xml:base" select="replace(base-uri(), '.+/', '')"/>-->
  </xsl:template>
  
</xsl:stylesheet>