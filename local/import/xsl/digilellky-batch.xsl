<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:php="http://php.net/xsl"
    xmlns:xlink="http://www.w3.org/2001/XMLSchema-instance">
    <xsl:output method="xml" indent="yes" encoding="utf-8"/>
    <xsl:param name="institution">Namn</xsl:param>
    <xsl:param name="collection">Samling</xsl:param>
    <xsl:template match="/">
        <xsl:if test="collection">
            <collection>
            <xsl:for-each select="collection">
                <xsl:for-each select="oai_dc:dc">
                    <xsl:apply-templates select="."/>
                </xsl:for-each>
            </xsl:for-each>
            </collection>
        </xsl:if>
        <xsl:if test="oai_dc:dc">
            <xsl:apply-templates/>
        </xsl:if>
    </xsl:template>
    <xsl:template match="oai_dc:dc">
        <add>
            <doc>
                <!-- ID -->
                <!-- Important: This relies on an <identifier> tag being injected by the OAI-PMH harvester. -->
                <field name="id">
                    <xsl:value-of select="identifier"/>
                </field>

                <!-- RECORDTYPE -->
                <field name="record_format">digilellky</field>

                <!-- FULLRECORD -->
                <!-- disabled for now; records are so large that they cause memory problems!
                <field name="fullrecord">
                    <xsl:copy-of select="php:function('VuFind::xmlAsText', //oai_dc:dc)"/>
                </field>
                  -->

                <!-- ALLFIELDS -->
                <field name="allfields">
                    <xsl:value-of select="normalize-space(string(oai_dc:dc))"/>
                </field>

                <!-- INSTITUTION -->
                <field name="institution">
                    <xsl:value-of select="$institution" />
                </field>

                <!-- COLLECTION -->
                <field name="collection">
                    <xsl:value-of select="$collection" />
                </field>

                <!-- LANGUAGE -->
                <xsl:if test="dc:language">
                    <xsl:for-each select="dc:language">
                        <xsl:if test="string-length() > 0">
                            <field name="language">
                                <xsl:value-of select="php:function('VuFind::mapString', normalize-space(string(.)), 'language_map_iso639-1.properties')"/>
                            </field>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:if>

                <!-- FORMAT mappa övers? -->
                <!-- field name="format">Music Score</field> -->
                <xsl:if test="dc:type">
                    <xsl:if test="string-length() > 0">
                        <field name="format">
                            <xsl:value-of select="dc:type[normalize-space()]"/>
			</field>
		    </xsl:if>
                </xsl:if>

		<!-- AUTHOR -->
                <xsl:if test="dc:creator">
		    <xsl:for-each select="dc:creator">
         		<xsl:if test="normalize-space()">
			    <field name="author">
                        	<xsl:value-of select="normalize-space()"/>
                	    </field>
			    <!-- use first author value for sorting -->
                            <xsl:if test="position()=1">
                                <field name="author_sort">
                                    <xsl:value-of select="normalize-space()"/>
                                </field>
                            </xsl:if>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:if>

                <!-- TITLE -->
                <xsl:if test="dc:title[normalize-space()]">
                    <field name="title">
                        <xsl:value-of select="dc:title[normalize-space()]"/>
                    </field>
                    <field name="title_short">
                        <xsl:value-of select="dc:title[normalize-space()]"/>
                    </field>
                    <field name="title_full">
                        <xsl:value-of select="dc:title[normalize-space()]"/>
                    </field>
                    <field name="title_sort">
                        <xsl:value-of select="php:function('VuFind::stripArticles', string(dc:title[normalize-space()]))"/>
                    </field>
                </xsl:if>
                
                <xsl:if test="dc:description">
		    <xsl:if test="normalize-space()">
			<field name="description">
			    Placering:<xsl:for-each select="dc:description"><xsl:value-of select="normalize-space()"/><xsl:if test="position()!=last()"><xsl:text>. </xsl:text></xsl:if></xsl:for-each>
                    	</field>
	            </xsl:if>
		</xsl:if>

                <!-- PUBLISHER -->
                <xsl:if test="dc:publisher[normalize-space()]">
                    <field name="publisher">
                        <xsl:value-of select="dc:publisher[normalize-space()]"/>
                    </field>
                </xsl:if>

                <!-- PUBLISHDATE -->
                <!-- xsl:if test="dc:date">
                    <field name="publishDate">
                        <xsl:value-of select="substring(dc:date, 1, 4)"/>
                    </field>
                    <field name="publishDateSort">
                        <xsl:value-of select="substring(dc:date, 1, 4)"/>
                    </field>
                </xsl:if -->

                <!-- GENRE -->
                <xsl:if test="dc:subject">
                    <xsl:for-each select="dc:subject">
                        <xsl:if test="normalize-space()">
                            <field name="genre">
                                <xsl:value-of select="normalize-space()"/>
                            </field>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:if>

                <!-- URL -->
                <!-- xsl:if test="dc:identifier">
                    <field name="url">
                        <xsl:value-of select="dc:identifier[normalize-space()]"/>
                    </field>
                </xsl:if -->


                <!-- URL and thumbnail -->
                <xsl:if test="dc:identifier">
                    <field name="url">
                        <xsl:value-of select="dc:identifier[normalize-space()]"/>
                    </field>
		    <field name="thumbnail">
			<xsl:variable name="box" select="substring-after(substring-before(dc:identifier[normalize-space()],'&amp;cc'),'dd=')"/>
			<xsl:variable name="box_len" select="string-length($box)"/>
			<xsl:variable name="box_pad" select="substring(concat('00', $box), $box_len)"/>
			<xsl:variable name="card" select="substring-after(dc:identifier[normalize-space()],'cc=')"/>
			<xsl:variable name="card_len" select="string-length($card)"/>
			<xsl:variable name="card_pad_0" select="substring(concat('000', $card), $card_len - 1, 4)"/>
			<xsl:variable name="card_pad_x" select="substring(concat('000', $card), $card_len, 4)"/>
			<xsl:text>https://digilellky.musikverket.se/kort/jpg/</xsl:text>
			<xsl:value-of select="$box_pad"/>
			<xsl:text>/</xsl:text>
			<xsl:value-of select="$box_pad"/>
			<xsl:text>_</xsl:text>
			<xsl:choose>
			    <xsl:when test="substring($card,$card_len)='0'">
				<xsl:value-of select="$card_pad_0"/>
			    </xsl:when>
			    <xsl:otherwise>
				<xsl:value-of select="$card_pad_x"/>
			    </xsl:otherwise>
			</xsl:choose>
			<xsl:text>.jpg</xsl:text>
		   </field>
                </xsl:if> 
           </doc>
        </add>
    </xsl:template>
</xsl:stylesheet>
