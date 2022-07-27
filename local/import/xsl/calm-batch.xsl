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

                <!-- RECORDTYPE CALM -->
                <field name="record_format">calm</field>

                <!-- FULLRECORD -->
                <!-- disabled for now; records are so large that they cause memory problems!
                <field name="fullrecord">
                    <xsl:copy-of select="php:function('VuFind::xmlAsText', //oai_dc:dc)"/>
                </field>
                  -->

                <!-- ALLFIELDS - CALM DC:* -->
                <field name="allfields">
                    <xsl:value-of select="normalize-space(string(descendant-or-self::*))"/>
                </field>

                <!-- INSTITUTION - CALM DC:DESCRIPTION -->
                <xsl:if test="dc:description[normalize-space()]">
                	<xsl:variable name="inst" select="substring-after(normalize-space(),'Förvarande institution: ')" />
		    		<xsl:if test="$inst">
				<field name="institution">
					<xsl:value-of select="substring-before($inst,'.')"/>
                    		</field>
	            	</xsl:if>
		</xsl:if>

                <!-- COLLECTION - PARAMETER -->
                <field name="collection">
                    <xsl:value-of select="$collection" />
                </field>   
                
                <!-- PHYSICAL - CALM DC:FORMAT -->
                <xsl:if test="dc:format[normalize-space()]">
			<field name="physical">
				<xsl:for-each select="dc:format[normalize-space()]">					
					<xsl:value-of select="normalize-space()"/>
					<xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if>
				</xsl:for-each>
                   	</field>
		</xsl:if>

                <!-- FORMAT - CALM DC:TYPE -->
                <xsl:if test="dc:type[normalize-space()]">
                    <field name="format">
                    	<xsl:value-of select="dc:type[normalize-space()]"/>
		    </field>
                </xsl:if>

		<!-- AUTHOR, AUTHOR_SORT, AUTHOR2 - CALM DC:CREATOR -->
                <xsl:if test="dc:creator[normalize-space()]">
		    		<xsl:for-each select="dc:creator[normalize-space()]">
						<xsl:choose>
	                        <xsl:when test="position()=1">
	                        	<!-- Skapare -->
			    		<xsl:variable name="author1" select="normalize-space()"/>
			    		<field name="author">
		                      		<xsl:value-of select="$author1"/>
		              	    	</field>                        
	                            <field name="author_sort">
	                                <xsl:value-of select="$author1"/>
	                            </field>
	                        </xsl:when>
	                        <xsl:otherwise>
		                        <!-- Medverkande -->                        
				    	<field name="author2">
	                        		<xsl:value-of select="normalize-space()"/>
	                	    	</field>                        	
	                        </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:if>
                
		<!-- AUTHOR2 - CALM DC:CONTRIBUTOR -->
                <xsl:if test="dc:contributor[normalize-space()]">
		    <xsl:for-each select="dc:contributor[normalize-space()]">
	                <!-- Medverkande --> 
		    		<field name="author2">
                       		<xsl:value-of select="normalize-space()"/>
               	    	</field>
                    </xsl:for-each>
                </xsl:if>            
    
                <!-- TITLE, TITLE_SHORT, TITLE_FULL, TITLE_SORT - CALM DC:TITLE -->
                <xsl:if test="dc:title[normalize-space()]">
                    <xsl:variable name="dc_title" select="dc:title[normalize-space()]"/>                
		    <field name="title">
                        <xsl:value-of select="$dc_title"/>
                    </field>
                    <field name="title_short">
                        <xsl:value-of select="$dc_title"/>
                    </field>
                    <field name="title_full">
                        <xsl:value-of select="$dc_title"/>
                    </field>
                    <field name="title_sort">
                        <xsl:value-of select="php:function('VuFind::stripArticles', string($dc_title))"/>
                    </field>
                </xsl:if>
                
                <!-- DESCRIPTION - CALM DC:DESCRIPTION -->
                <xsl:if test="dc:description[normalize-space()]">
			<field name="description">
				<xsl:for-each select="dc:description[normalize-space()]">		
					<xsl:if test="not(substring-after(normalize-space(),'Förvarande institution: '))">
						<xsl:value-of select="normalize-space()"/>
						<xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if>
					</xsl:if>
				</xsl:for-each>
                   	</field>
		</xsl:if>
				
                <!-- PUBLISHDATE, PUBLICDATESORT, DATESPAN - CALM DC:DATE -->
                <xsl:if test="dc:date[normalize-space()]">
                	<xsl:variable name="date" select="dc:date[normalize-space()]"/>
					<xsl:variable name="ca" select="substring-after(translate($date,'C','c'),'ca ')"/>
                    <field name="publishDate">
                    	<xsl:value-of select="$date"/>
                    </field>					
                    <field name="publishDateSort">
                    	<xsl:choose>
				<xsl:when test="$ca">
					<xsl:value-of select="substring($ca, 1, 4)"/>							
				</xsl:when>               
                    		<xsl:otherwise>
                    			<xsl:value-of select="substring($date, 1, 4)"/>
                    		</xsl:otherwise>
                        </xsl:choose>
                    </field>
                    <xsl:if test="substring-before($date,'-')">
	                    <field name="dateSpan">
                    		<xsl:choose>
					<xsl:when test="$ca">
						<xsl:value-of select="$ca"/>							
					</xsl:when>               
                    			<xsl:otherwise>
                    				<xsl:value-of select="$date"/>
                    			</xsl:otherwise>
                        	</xsl:choose>
        	            </field>
                    </xsl:if>
                </xsl:if>

                <!-- GEOGRAPHIC, PUBLISHDATE, PUBLICDATESORT, DATESPAN - CALM DC:COVERAGE -->
                <xsl:if test="dc:coverage[normalize-space()]">
                	<xsl:for-each select="dc:coverage[normalize-space()]">
	                	<xsl:choose>
	                		<xsl:when test="not(translate(.,'0123456789.+-/* ',''))">
	                		    <!-- Tillverkningstid => publishDate -->
	                		    <!-- Här borde även testas om dc:date finns; men det borde det inte göra -->
	                		   <xsl:variable name="coverage" select="."/>
	                		   <xsl:variable name="ca" select="substring-after(translate($coverage,'C','c'),'ca ')"/>      	
			                   <field name="publishDate">
			                    	<xsl:value-of select="$coverage"/>
			                   </field>					
			                   <field name="publishDateSort">
			                    	<xsl:choose>
							<xsl:when test="substring-after(translate($coverage,'C','c'),'ca ')">
								<xsl:value-of select="substring($ca, 1, 4)"/>							
							</xsl:when>               
			                    		<xsl:otherwise>
			                    			<xsl:value-of select="substring($coverage, 1, 4)"/>
			                    		</xsl:otherwise>
			                        </xsl:choose>
			                    </field>
			                    <xsl:if test="substring-before($coverage,'-')">
				                    <field name="dateSpan">
			                    		<xsl:choose>
								<xsl:when test="$ca">
									<xsl:value-of select="$ca"/>							
								</xsl:when>               
			                    			<xsl:otherwise>
			                    				<xsl:value-of select="$coverage"/>
			                    			</xsl:otherwise>
			                        	</xsl:choose>
			        	            </field>
			                    </xsl:if>
	                		</xsl:when>
	                		<xsl:otherwise>
	                			<!-- Motivplats, Tillverkningsplats => geographic -->
	                			<xsl:if test="normalize-space()">
			                    	<field name="geographic">
			                       		<xsl:value-of select="normalize-space()"/>
			                    	</field>
	                			</xsl:if>			                                    			
	                		</xsl:otherwise>   		                    
	                	</xsl:choose>
	                </xsl:for-each>		                    
                </xsl:if>

                <!-- GENRE - CALM DC:SUBJECT -->
                <xsl:if test="dc:subject[normalize-space()]">
                    <xsl:for-each select="dc:subject[normalize-space()]">
                        <field name="genre">
                            <xsl:value-of select="normalize-space()"/>
                        </field>
                    </xsl:for-each>
                </xsl:if>

                <!-- URL - CALM DC:IDENTIFIER -->
                <xsl:if test="dc:identifier[normalize-space()]">
                    <field name="url">
                        <xsl:value-of select="dc:identifier[normalize-space()]"/>
                    </field>
                </xsl:if>
            </doc>
        </add>
    </xsl:template>

   	<xsl:template match="record">
		<xsl:apply-templates select="."/>
	</xsl:template> 
    
</xsl:stylesheet>
