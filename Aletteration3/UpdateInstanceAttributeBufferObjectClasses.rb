#
#  UpdateInstanceAttributeBufferObjectClasses.rb
#  Aletteration3
#
#  Created by David Nesbitt on 2013/10/7.
#  Copyright (c) 2013 David Nesbitt. All rights reserved.
#

def writeVertexBufferObjectFiles (typeName, structHash)
	currentDate = Time.new.strftime("%Y/%m/%d")
	currentYear = Time.new.strftime("%Y")
	
	if typeName =~ /NezInstanceAttribute(\w+)/ then
		className = 'NezInstanceAttributeBufferObject'+$1
	else
		className = 'NezInstanceAttributeBufferObject'+typeName
	end

	File.open(className+'.h', 'w') do |f2|
		f2.puts('//')
		f2.puts('//  '+className+'.h')
		f2.puts('//  Aletteration3')
		f2.puts('//')
		f2.puts('//  Created by David Nesbitt on '+currentDate+'.')
		f2.puts('//  Copyright (c) '+currentYear+' David Nesbitt. All rights reserved.')
		f2.puts('//')
		f2.puts('')
		f2.puts('#import "NezInstanceAttributeBufferObject.h"')
		f2.puts('')
		f2.puts('@interface '+className+' : NezInstanceAttributeBufferObject')
		f2.puts('')
		f2.puts('@property (readonly, getter = getInstanceAttributeList) '+typeName+' *instanceAttributeList;')
		f2.puts('')
		f2.puts('@end')
	end

	File.open(className+'.m', 'w') do |f2|
		f2.puts('//')
		f2.puts('//  '+className+'.m')
		f2.puts('//  Aletteration3')
		f2.puts('//')
		f2.puts('//  Created by David Nesbitt on '+currentDate+'.')
		f2.puts('//  Copyright (c) '+currentYear+' David Nesbitt. All rights reserved.')
		f2.puts('//')
		f2.puts('')
		f2.puts('#import "'+className+'.h"')
		f2.puts('#import "NezGLSLProgram.h"')
		f2.puts('')
		f2.puts('@implementation '+className)
		f2.puts('')
		f2.puts('-(instancetype)initWithInstanceCount:(GLsizei)instanceCount {')
		f2.puts('	if ((self = [super initWithInstanceCount:instanceCount])) {')
		f2.puts('		'+typeName+' *aDst = self.instanceAttributeList;');
		f2.puts('		for (NSInteger i=0; i<instanceCount; i++) {')
		structHash.each_key {|key|
			if structHash[key] == 'GLKMatrix4' then
		f2.puts('			aDst[i].'+key+' = GLKMatrix4Identity;')
			elsif structHash[key] == 'GLKVector2' then
		f2.puts('			aDst[i].'+key+' = GLKVector2Make(0.0f, 0.0f);')
			elsif structHash[key] == 'GLKVector3' then
		f2.puts('			aDst[i].'+key+' = GLKVector3Make(0.0f, 0.0f, 0.0f);')
			elsif structHash[key] == 'GLKVector4' then
		f2.puts('			aDst[i].'+key+' = GLKVector4Make(0.0f, 0.0f, 0.0f, 0.0f);')
			elsif structHash[key] == 'GLKQuaternion' then
		f2.puts('			aDst[i].'+key+' = GLKQuaternionIdentity;')
			elsif structHash[key] == 'float' then
		f2.puts('			aDst[i].'+key+' = 0.0f;')
			end
		}
		f2.puts('		}')
		f2.puts('	}')
		f2.puts('	return self;')
		f2.puts('}')
		f2.puts('')
		f2.puts('-(GLsizei)getSizeofInstanceAttribute {')
		f2.puts('	return sizeof('+typeName+');')
		f2.puts('}')
		f2.puts('')
		f2.puts('-('+typeName+'*)getInstanceAttributeList {')
		f2.puts('	return ('+typeName+'*)_instanceData.bytes;')
		f2.puts('}')
		f2.puts('')
		f2.puts('-(void)enableInstanceVertexAttributesForProgram:(NezGLSLProgram*)program {')
		structHash.each_key {|key|
			if structHash[key] == 'float' then
		f2.puts('	[self enableInstanceVertexAttributeWithLocation:program.a_'+key+' size:1 stride:self.sizeofInstanceAttribute offset:(void*)offsetof('+typeName+', '+key+')];')
				elsif structHash[key] == 'GLKVector2' then
		f2.puts('	[self enableInstanceVertexAttributeWithLocation:program.a_'+key+' size:2 stride:self.sizeofInstanceAttribute offset:(void*)offsetof('+typeName+', '+key+')];')
				elsif structHash[key] == 'GLKVector3' then
		f2.puts('	[self enableInstanceVertexAttributeWithLocation:program.a_'+key+' size:3 stride:self.sizeofInstanceAttribute offset:(void*)offsetof('+typeName+', '+key+')];')
				elsif structHash[key] == 'GLKVector4' then
		f2.puts('	[self enableInstanceVertexAttributeWithLocation:program.a_'+key+' size:4 stride:self.sizeofInstanceAttribute offset:(void*)offsetof('+typeName+', '+key+')];')
				elsif structHash[key] == 'GLKQuaternion' then
		f2.puts('	[self enableInstanceVertexAttributeWithLocation:program.a_'+key+' size:4 stride:self.sizeofInstanceAttribute offset:(void*)offsetof('+typeName+', '+key+')];')
				elsif structHash[key] == 'GLKMatrix4' then
		f2.puts('	[self enableInstanceVertexAttributeWithLocation:program.a_'+key+'Column0 size:4 stride:self.sizeofInstanceAttribute offset:(void*)offsetof('+typeName+', '+key+'.m00)];')
		f2.puts('	[self enableInstanceVertexAttributeWithLocation:program.a_'+key+'Column1 size:4 stride:self.sizeofInstanceAttribute offset:(void*)offsetof('+typeName+', '+key+'.m10)];')
		f2.puts('	[self enableInstanceVertexAttributeWithLocation:program.a_'+key+'Column2 size:4 stride:self.sizeofInstanceAttribute offset:(void*)offsetof('+typeName+', '+key+'.m20)];')
		f2.puts('	[self enableInstanceVertexAttributeWithLocation:program.a_'+key+'Column3 size:4 stride:self.sizeofInstanceAttribute offset:(void*)offsetof('+typeName+', '+key+'.m30)];')
			end
		}
		f2.puts('}')
		f2.puts('')
		f2.puts('@end')
	end
end

structHash = Hash.new
isStruct = false
foundStructFirstMember = false;
structFirstMember = '';
structName = ''
Dir.chdir('Classes/Graphics/InstanceAttributeBuffer')
File.new('NezInstanceAttributeTypes.h', 'r').each { |line|
	if isStruct then
		if line =~ /\s*(\w+)\s+(\w+)\s*\;/ then
			structHash[$2] = $1
		elsif line =~ /\s*(\w+)\s*\;/ then
			writeVertexBufferObjectFiles($1, structHash)
			isStruct = false
		end
	else
	if line =~ /\s*typedef\s+struct\s*\{/ then
			isStruct = true;
			structHash = Hash.new
		end
	end
}
