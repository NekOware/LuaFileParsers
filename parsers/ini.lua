

local eschrs = { ['"']='"' ,["'"]="'" ,[';']=';' ,['#']='#' ,['=']='=' ,[':']=':',
                 ['0']='\0',['a']='\a',['b']='\b',['t']='\t',['r']='\r',['n']='\n',
                 ['\\']='\\' }

local uneschrs={ ['"']='\\"',["'"]="\\'",[';']='\\;',['#']='\\#',['=']='\\=',[':']='\\:',
                 ['\0']='0',['\a']='a',['\b']='b',['\t']='t',['\r']='r',['\n']='n',
                 ['\\']='\\' }



local key_val_from_line=function(line)
  local key,tval = line:match('^%s*([^=]+)=?%s*(.-)%s*$')
  if(key and tval)==nil then return end
  key = key:match('^%s*(.-)%s*$')
  local pval = tonumber(tval)
  if pval==nil then if tval=='true'then pval=true elseif tval=='false'then pval=false end end
  if pval~=nil then return key,pval end
  do
    local parts,out={},''
    local str,esc='',0
    local _=tval:gsub('.',function(c)
      if str==''then
        if esc%2==0 and(c=='"'or"'"==c)then str=c; table.insert(parts,out)out=''end
        out=out..c
      else
        if esc%2==0 and c==str then str,esc='',0 table.insert(parts,out..c)out=''
        else out=out..c
        end
      end
      if c=='\\'or(eschrs[c]and esc%2~=0)then esc=esc+1
      else --[[if esc%2~=0 then out=out:sub(1,-2)..'\\'..out:sub(-1,-1)end]] esc=0 end
    end)
    table.insert(parts,out)
    for i=1,#parts do
      if parts[i]==''then parts[i]='""'
      elseif not(parts[i]:match('^".-"$')or parts[i]:match("^'.-'$"))then
        parts[i]='"'..parts[i]:match('^%s*(.-)%s*$')..'"'
      end
      parts[i]=parts[i]:gsub('([\\]+)(.?)',function(e,c)
        if #e%2==0 then return(e..c)else return(eschrs[c]and(e..c)or e:sub(1,-2))end
      end)
    end --p(parts)
    local res=load('return('..table.concat(parts,'..')..')')()
    return key,res
  end
end



local sect_table = function()
  local out={}
  local add_path=function(sect,key,val)
    local p,o={},nil
    local pat=''
    for part in sect:gmatch('[^%.]+')do
      table.insert(p,(part:gsub('([\\]*)(")',function(e,b)return(e..(#e%2==0 and'\\'or'')..b)end)))
      pat=table.concat(p,'"]["')
      load('out["'..pat..'"]=(out["'..pat..'"]or{})','owo','*t',setmetatable({out=out},{__index=_G}))()
    end
    if key then
      load('out["'..pat..'"][key]=val','owo','*t',setmetatable({out=out,key=key,val=val},{__index=_G}))()
    end
  end
  local put=function(sect,key,val)
    sect=sect or''
    if not sect or sect==''then
      out=(out or{})
      if key then out[key]=val end
    elseif tonumber(sect)then
      out[tonumber(sect)]=(out[tonumber(sect)]or{})
      if key then out[tonumber(sect)][key]=val end
    else
      add_path(sect,key,val)
    end
    return out
  end
  return function()return out end,put
end



local load=function(data)
  assert(type(data)=='string','[INI-parser]: load: Param "data" (Arg#1) must be a string.')
  do
    local com,str,esc=false,'',0
    local pos=0
    data=data
      :gsub('.',function(c)
        if str==''then esc=0
          if not com and(c==';'or'#'==c)then com=true
          elseif com and c=='\n'then com=false
          elseif not com and(c=='"'or"'"==c)then str=c
          end
        else
          if c==str and esc%2==0 then str,esc='',0
          else if c=='\\'or(eschrs[c]and esc%2~=0)then esc=esc+1 else esc=0 end
          end
        end
        return(com and''or c)
      end)
      :gsub('([\\]+)(\r?\n)',function(e,n)
        if #e%2==0 then return(e..n)else return(e:sub(1,-2))end
      end)
  end
  local out,put=sect_table()
  local section
  for line in data:gmatch('[^\r\n]+')do
    local sec_name = line:match('^%s*%[([^%[%]]*)%]%s*$')
    if sec_name then
      if sec_name:sub(1,1)=='.'then section=((section and section..sec_name)or(sec_name:sub(2)))
      else section=sec_name
      end
      local c=1
      repeat section,c=section:gsub('[^%.]*%.%.','')until c<=0
      section:gsub('^[%.]*',''):gsub('[%.]*$','')
    else
      local key,val = key_val_from_line(line)
      if key then put(section,key,val)end
    end
  end
  return out()
end



local loadFile = function(path)
  assert(type(path)=='string','[INI-parser]: loadFile: Param "path" (Arg#1) must be a string.')
  local file = io.open(path,'rb')
  if not file then return end
  local data = file:read('*a')
  file:close()
  return load(data)
end



local dump_table;dump_table=function(tbl,path)
  local out={}
  if path then table.insert(out,'\n['..path..']')end
  for i,v in pairs(tbl)do
    if type(v)~='table'then
      local q = (type(v)=='string'and'"'or'')
      local w = (function()
        if type(v)=='string'then
          return(v:gsub('(.)',function(c)return(uneschrs[c]or c)end))
        else return v
        end
      end)()
      table.insert(out,i..'='..q..w..q)
      tbl[i]=nil
    end
  end
  for k,v in pairs(tbl)do
    if type(v)=='table'then
      local p = (path and path..'.'..k)or k
      local t = dump_table(v,p)
      for i=1,#t do table.insert(out,t[i])end
    end
  end
  return out
end



local save = function(data)
  assert(type(data)=='table','[INI-parser]: save: Param "data" (Arg#1) must be a table.')
  local dump = dump_table(data)
  return'\n'..table.concat(dump,'\n')..'\n'
end



local saveFile = function(path,data)
  assert(type(path)=='string','[INI-parser]: saveFile: Param "path" (Arg#1) must be a string.')
  assert(type(data)=='table','[INI-parser]: saveFile: Param "data" (Arg#2) must be a table.')
  local dump = dump_table(data)
  local file = io.open(path,'wb')
  if not file then return end
  file:write('\n'..table.concat(dump,'\n')..'\n')
  file:close()
  return true
end



return {
  load=load,
  loadFile=loadFile,
  save=save,
  saveFile=saveFile
}

