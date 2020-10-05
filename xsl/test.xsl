<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:jats="http://jats.nlm.nih.gov"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
  exclude-result-prefixes="#all">

  <xsl:output indent="yes" method="xml"/>

  <xsl:param name="base-dir-uri" as="xs:string"/>

  <xsl:template name="main">
    <xsl:variable name="html-docs" as="document-node()*"
      select="collection($base-dir-uri || '?recurse=yes;select=*.xhtml')"/>
    <xsl:variable name="element-lists" as="element(xhtml:ul)*" select="$html-docs/xhtml:html/xhtml:body/xhtml:ul[1]"/>
    <xsl:message select="'Counts: ', $element-lists ! count(xhtml:li)"/>
    <xsl:variable name="customizations" as="document-node(element(customizations))">
      <xsl:document>
        <customizations>
          <xsl:for-each select="$element-lists">
            <xsl:variable name="outer" as="element(xhtml:ul)" select="."/>
            <customization name="{xhtml:notdir(base-uri($outer))}" elements="{count(xhtml:li)}">
              <xsl:for-each select="$element-lists except $outer">
                <xsl:variable name="inner" as="element(xhtml:ul)" select="."/>
                <xsl:variable name="not-in" as="element(xhtml:li)*" select="$outer/xhtml:li[not(. = $inner/xhtml:li)]"/>
                <elements not-in="{xhtml:notdir(base-uri($inner))}" count="{count($not-in)}">
                  <xsl:value-of select="$not-in"/>
                </elements>
              </xsl:for-each>
            </customization>
          </xsl:for-each>
        </customizations>
      </xsl:document>
    </xsl:variable>
    <xsl:apply-templates select="$customizations" mode="compute"/>
  </xsl:template>

  <xsl:mode name="compute" on-no-match="shallow-copy"/>

  <xsl:key name="ij" match="customization/*[@not-in]" use="string-join((@not-in, ../@name), ',')"/>

  <xsl:template match="customization/*[@not-in]" mode="compute">
    <xsl:variable name="a_ij" as="xs:integer" select="@count">
      <!-- Elements of the current customization that are not in the customization referenced by @not-in.
      If this is 0, then the @not-in customization is a superset of the current. -->
    </xsl:variable>
    <xsl:variable name="a_ji" as="xs:integer" select="key('ij', string-join((../@name, @not-in), ','))/@count"/>
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:variable name="distance" select="$a_ij + $a_ji" as="xs:integer"/>
      <xsl:attribute name="distance" select="$distance"/>
      <xsl:if test="$distance gt 0">
        <xsl:variable name="total" as="xs:double" select="../@*[name() = name(current())]">
          <!-- ../@elements for name(current()) = 'elements' -->
        </xsl:variable>
        <xsl:variable name="r_ij" as="xs:double" select="$a_ij"/>
        <xsl:variable name="r_ji" as="xs:double" select="$a_ji div $distance"/>
        <xsl:variable name="supersetticity1" select="$a_ji - $a_ij" as="xs:integer"/>
        <xsl:variable name="supersetticity2" select="$a_ji div (1 + $a_ij)" as="xs:double"/>
        <xsl:variable name="supersetticity4" select="(1 + $a_ji) div (1 + $a_ij)" as="xs:double"/>
        <xsl:variable name="supersetticity5" select="(1 + $r_ji) div (1 + $r_ij)" as="xs:double"/>
        <xsl:variable name="q1" as="xs:double" select="$supersetticity1 div $distance"/>
        <xsl:variable name="q2" as="xs:double" select="$supersetticity2 div $distance"/>
        <xsl:variable name="q3" as="xs:double" select="$supersetticity1 div ($distance * $distance)"/>
        <xsl:variable name="q4" as="xs:double" select="($supersetticity4 div $distance) * 100"/>
        <xsl:variable name="q5" as="xs:double" select="($supersetticity5 div $distance) * 100"/>
        <xsl:attribute name="s1" select="$supersetticity1"/>
        <xsl:attribute name="s2" select="format-number($supersetticity2, '.##')"/>
        <xsl:attribute name="s4" select="format-number($supersetticity4, '.##')"/>
        <xsl:attribute name="s5" select="format-number($supersetticity5, '.##')"/>
        <xsl:attribute name="q1" select="format-number($q1, '.##')"/>
        <xsl:attribute name="q2" select="format-number($q2, '.##')"/>
        <xsl:attribute name="q3" select="format-number($q3, '.##')"/>
        <xsl:attribute name="q4" select="format-number($q4, '.##')"/>
        <xsl:attribute name="q5" select="format-number($q5, '.##')"/>
        <xsl:comment>
s: “supersetticity” of <xsl:value-of select="@not-in"/> with respect to <xsl:value-of select="../@name"/>
q: degree to which <xsl:value-of select="@not-in"/> is suitable to derive <xsl:value-of select="../@name"/> from
        </xsl:comment>
      </xsl:if>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>


  <xsl:function name="xhtml:notdir" as="xs:string">
    <xsl:param name="uri" as="xs:string"/>
    <xsl:sequence select="tokenize($uri, '/')[last()] => replace('_expanded', '')"/>
  </xsl:function>

</xsl:stylesheet>
