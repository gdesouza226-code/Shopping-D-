(function(){
  const cfg=window.SUPABASE_CONFIG||{};
  const configured=cfg.url && cfg.anonKey && !cfg.url.startsWith('COLE_') && !cfg.anonKey.startsWith('COLE_');
  const client=configured?window.supabase.createClient(cfg.url,cfg.anonKey):null;
  window.portalCloud={
    configured, client,
    async load(){
      if(!client) throw new Error('Supabase ainda não configurado.');
      const {data,error}=await client.from('portal_config').select('dados').eq('id',1).maybeSingle();
      if(error) throw error;
      return data?.dados||JSON.parse(JSON.stringify(window.DADOS_INICIAIS));
    },
    async save(dados){
      const {error}=await client.from('portal_config').upsert({id:1,dados,atualizado_em:new Date().toISOString()});
      if(error) throw error;
    },
    async upload(file,prefix){
      const safe=file.name.normalize('NFD').replace(/[\u0300-\u036f]/g,'').replace(/[^a-zA-Z0-9._-]/g,'-');
      const path=`${prefix}/${Date.now()}-${safe}`;
      const {error}=await client.storage.from(cfg.bucket||'treinamentos').upload(path,file,{upsert:false});
      if(error) throw error;
      return {path,url:client.storage.from(cfg.bucket||'treinamentos').getPublicUrl(path).data.publicUrl};
    },
    async remove(path){if(!path)return;const {error}=await client.storage.from(cfg.bucket||'treinamentos').remove([path]);if(error)throw error;}
  };
})();
