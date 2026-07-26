import type { SupabaseClient } from "npm:@supabase/supabase-js@2";

export async function deleteUserFiles(
  admin: SupabaseClient,
  userId: string,
) {
  await deleteFolder(admin, "profile", `avatars/${userId}`);
  await deleteFolder(admin, "profile", `goals/${userId}`);
  await deleteFolder(admin, "receipts", userId);
}

async function deleteFolder(
  admin: SupabaseClient,
  bucketName: string,
  folder: string,
): Promise<void> {
  const bucket = admin.storage.from(bucketName);
  while (true) {
    const { data, error } = await bucket.list(folder, { limit: 100 });
    if (error) {
      if (error.message.toLowerCase().includes("not found")) return;
      throw error;
    }
    if (!data?.length) return;
    const files = data.filter((item) => item.id != null);
    const folders = data.filter((item) => item.id == null);
    if (files.length > 0) {
      const { error: removeError } = await bucket.remove(
        files.map((file) => `${folder}/${file.name}`),
      );
      if (removeError) throw removeError;
    }
    for (const child of folders) {
      await deleteFolder(admin, bucketName, `${folder}/${child.name}`);
    }
    if (data.length < 100) return;
  }
}
